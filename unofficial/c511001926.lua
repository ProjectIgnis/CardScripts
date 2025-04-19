--ファントム・オブ・カオス (Anime)
--Phantom of Chaos (Anime)
--Fixed by Larry126
local s,id,alias=GetID()
function s.initial_effect(c)
	alias = c:GetOriginalCodeRule()
	--copy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(alias,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--no battle damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	c:RegisterEffect(e2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc:IsType(TYPE_EFFECT) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_EFFECT) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_GRAVE,0,1,1,nil,TYPE_EFFECT)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc and tc:IsRelateToEffect(e) then
		local code=tc:GetOriginalCode()
		local ba=tc:GetBaseAttack()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(ba)
		c:RegisterEffect(e1)
		c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
	end
end