--Puppet King
local s,id=GetID()
function s.initial_effect(c)
	--summon with 1 tribute
	local e1=aux.AddNormalSummonProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0),s.otfilter)
end
s.listed_names={511002731}
function s.otfilter(c,tp)
	return c:IsCode(511002731) and (c:IsControler(tp) or c:IsFaceup())
end