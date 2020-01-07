--紫眼の黄金竜
--Purple-Eyes Golden Dragon
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.ffilter,2)
end
function s.cfilter(c,fc,sumtype,sp)
	return c:IsRace(RACE_DRAGON,fc,sumtype,sp) and c:IsType(TYPE_NORMAL,fc,sumtype,sp) and c:IsLevelAbove(5)
end
function s.ffilter(c,fc,sumtype,sp,sub,mg,sg)
	return s.cfilter(c,fc,sumtype,sp) and (not sg or sg:FilterCount(s.cfilter,c)==0 or not sg:IsExists(Card.IsAttribute,1,c,c:GetAttribute(),fc,sumtype,sp))
end