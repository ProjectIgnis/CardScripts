--炎を支配する者 (Rush)
--Flame Ruler (Rush)
--scripted by Cybercatman
local s,id=GetID()
function s.initial_effect(c)
	--double tribute
	c:AddDoubleTribute(id,s.otfilter,s.eftg,0,FLAG_DOUBLE_TRIB_FIRE)
end
function s.otfilter(c,tp)
	return c:IsDoubleTribute(FLAG_DOUBLE_TRIB_FIRE) and (c:IsControler(tp) or c:IsFaceup())
end
function s.eftg(e,c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLevelAbove(7) and c:IsSummonableCard()
end
