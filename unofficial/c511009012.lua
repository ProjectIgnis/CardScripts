--イーバ・イプシロン
--Eva Epsilon
local s,id=GetID()
function s.initial_effect(c)
	--Register Life Star Counters on this card
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_LEAVE_FIELD_P)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	--Place Life Star Counters on monsters equal to the number of Life Star Counters this card had
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39892082,1))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(s.ctcon)
	e1:SetOperation(s.ctop)
	e1:SetLabelObject(e0)
	c:RegisterEffect(e1)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetHandler():GetCounter(0x1109)
	e:SetLabel(ct)
end
function s.ctfilter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x1109,1)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabelObject():GetLabel()
	e:SetLabel(ct)
	return ct>0 and Duel.IsExistingMatchingCard(s.ctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	local g=Duel.GetMatchingGroup(s.ctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g==0 then return end
	for i=1,ct do
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(83604828,1))
		local sg=g:Select(tp,1,1,nil)
		sg:GetFirst():AddCounter(0x1109,1)
	end
end