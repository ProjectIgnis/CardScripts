--メテオ・スウォーム・エントリー・ドラゴン
--Meteor Swarm Entry Dragon
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,160015028,1,s.ffilter,1)
end
s.named_material={160015028}
function s.ffilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH|ATTRIBUTE_DARK,scard,sumtype,tp) and c:IsLevelAbove(6)
end