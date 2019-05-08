{% macro get_execution_relation() %}
    {%- set execution_table =
        api.Relation.create(
            identifier='execution',
            schema='dbt',
            type='table'
        ) -%}
    {{ return(execution_table) }}
{% endmacro %}


{% macro log_execution_event(status) %}
    insert into {{ pageup_dbt_utils.get_execution_relation() }} (
        execution_id,
        last_updated_on,
        is_full_refresh,
        status
        )

    values (
        '{{ invocation_id }}'::uuid,
        {{dbt_utils.current_timestamp_in_utc()}},
        {{ flags.FULL_REFRESH }},
        '{{ status }}'
        )

{% endmacro %}


{% macro create_execution_log_table() %}

    create table if not exists {{ pageup_dbt_utils.get_execution_relation() }}
    (
        execution_id        uuid PRIMARY KEY NOT NULL,
        created_on          {{dbt_utils.type_timestamp()}} DEFAULT current_timestamp,
        last_updated_on     {{dbt_utils.type_timestamp()}} NOT NULL,
        is_full_refresh     bit NOT NULL,
        status              varchar(512) NOT NULL
    )

{% endmacro %}


{% macro log_execution_start_event() %}
    {{pageup_dbt_utils.log_execution_event('started')}}
{% endmacro %}


{% macro log_execution_end_event() %}
    {{pageup_dbt_utils.log_execution_event('completed')}}; commit;
{% endmacro %}
