--Eva Epsilon
local s,id=GetID()
function s.initial_effect(c)
	--Give Counter
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39892082,1))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(s.damcon)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
end

function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetCounter(0x1109)
	e:SetLabel(ct)
	return ct>0 and c:IsLocation(LOCATION_GRAVE)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g==0 then return end
	for i=1,ct do
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(83604828,1))
		local tc=g:Select(tp,1,1,nil):GetFirst()
		tc:AddCounter(0x1109,1)
	end
end
