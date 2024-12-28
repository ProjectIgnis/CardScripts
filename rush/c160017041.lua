--マスドクロ
--Multiply Skull
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--double tribute
	c:AddDoubleTribute(id,s.otfilter,s.eftg,0,FLAG_DOUBLE_TRIB_DARK+FLAG_DOUBLE_TRIB_FIEND+FLAG_DOUBLE_TRIB_0_ATK+FLAG_DOUBLE_TRIB_0_DEF+FLAG_DOUBLE_TRIB_EFFECT)
end
function s.otfilter(c,tp)
	return c:IsDoubleTribute(FLAG_DOUBLE_TRIB_DARK+FLAG_DOUBLE_TRIB_FIEND+FLAG_DOUBLE_TRIB_0_ATK+FLAG_DOUBLE_TRIB_0_DEF+FLAG_DOUBLE_TRIB_EFFECT) and (c:IsControler(tp) or c:IsFaceup())
end
function s.eftg(e,c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FIEND) and c:IsType(TYPE_EFFECT) and c:IsAttack(0) and c:IsDefense(0) and c:IsLevelAbove(7) and c:IsSummonableCard()
end
