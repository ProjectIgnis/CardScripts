--神科学因子カスパール
--Mystic Factor Caspar
local s,id=GetID()
function s.initial_effect(c)
	--level up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44635489,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
end
function s.lvfilter(c)
	return c:IsFaceup() and not c:IsLevel(1) and c:IsLevelBelow(2147483647)
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsFaceup() and c:IsLevelAbove(3)
		and Duel.GetMatchingGroupCount(s.lvfilter,tp,LOCATION_MZONE,0,c)==Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)-1 end
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_MZONE,0,c)
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsLevelAbove(3) and #tg==Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)-1 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		for tc in aux.Next(tg) do
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CHANGE_LEVEL_FINAL)
			e2:SetValue(1)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
end
