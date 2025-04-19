--剛鬼スイシーダ
--Gouki Diver
local s,id=GetID()
function s.initial_effect(c)
	--Take no battle damage and decrease the ATK of an opponent's monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.damcon)
	e1:SetCost(aux.selfbanishcost)
	e1:SetOperation(s.dmop)
	c:RegisterEffect(e1)
	--Search 1 "Gouki" card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GOUKI}
s.listed_names={id}
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end
function s.dmop(e,tp,eg,ep,ev,re,r,rp)
	--Avoid battle damage
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetOperation(s.damop)
	e1:SetReset(RESET_PHASE|PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
	local a=Duel.GetAttacker()
	if a:IsRelateToBattle() and not a:IsImmuneToEffect(e) and a:IsControler(1-tp) then
		--Decrease the ATK by 600 and force a second attack in a row
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EVENT_BATTLED)
		e2:SetRange(LOCATION_MZONE)
		e2:SetLabelObject(a)
		e2:SetOperation(s.atkop)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE)
		a:RegisterEffect(e2)
	end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(tp,0)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local a=e:GetLabelObject()
	if a:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(a:GetBaseAttack()-600)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		a:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_MUST_ATTACK)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE)
		a:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_FIRST_ATTACK)
		a:RegisterEffect(e3)
		Duel.ChainAttack()
	end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.thfilter(c)
	return c:IsSetCard(SET_GOUKI) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end