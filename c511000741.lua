--Lefty Driver
local s,id=GetID()
function s.initial_effect(c)
	--synchro level
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SYNCHRO_LEVEL)
	e2:SetCondition(s.scon)
	e2:SetValue(s.slevel)
	c:RegisterEffect(e2)
end
function s.scon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL
end
function s.slevel(e,c)
	local lv=e:GetHandler():GetLevel()
	return 3*65536+lv
end
