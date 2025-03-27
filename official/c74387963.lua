--ＤＤエクストラ・サーベイヤー
--D/D Extra Surveyor
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum Summon procedure
	Pendulum.AddProcedure(c)
	--Banish 2 cards from your Pendulum Zone and make 1 "D/D/D" monster able to make a second attack during each Battle Phase this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.rmvcon)
	e1:SetTarget(s.rmvtg)
	e1:SetOperation(s.rmvop)
	c:RegisterEffect(e1)
	--Add 1 face-up "D/D" Pendulum Monster from your Extra Deck to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfDiscard)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--Banish cards from the top of your opponent's Deck then you can make 1 "D/D" monster you control gain 200 ATK for each card banished
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.rmvatktg)
	e3:SetOperation(s.rmvatkop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_DD,SET_DDD}
s.listed_names={id}
function s.rmvconfilter(c,tp)
	return c:IsReason(REASON_BATTLE|REASON_EFFECT) and c:IsPreviousControler(1-tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsMonsterCard()
end
function s.rmvcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.rmvconfilter,1,nil,tp)
end
function s.tgfilter(c)
	return c:IsSetCard(SET_DDD) and c:IsFaceup() and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
function s.rmvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_PZONE,0,2,nil) 
		and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_PZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,tp,0)
end
function s.rmvop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_PZONE,0,nil)
	if #g<2 then return end
	local tc=Duel.GetFirstTarget()
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)==2 and tc:IsRelateToEffect(e) then
		--It can make a second attack during each Battle Phase this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3201)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_DD) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.rmvatktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsType,TYPE_PENDULUM),tp,0,LOCATION_EXTRA,nil)
	local g=Duel.GetDecktopGroup(1-tp,ct)
	if chk==0 then return ct>0 and g:FilterCount(Card.IsAbleToRemove,nil)==ct end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,ct,tp,0)
end
function s.rmvatkop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsType,TYPE_PENDULUM),tp,0,LOCATION_EXTRA,nil)
	local g=Duel.GetDecktopGroup(1-tp,ct)
	if ct==0 or #g==0 or ct>#g then return end
	Duel.DisableShuffleCheck()
	local atk=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	if atk>0 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_DD),tp,LOCATION_MZONE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
		local sc=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsSetCard,SET_DD),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if sc then
			Duel.HintSelection(sc)
			Duel.BreakEffect()
			sc:UpdateAttack(200*atk,RESET_EVENT|RESETS_STANDARD,e:GetHandler())
		end
	end
end