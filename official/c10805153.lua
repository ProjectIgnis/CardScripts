--ウィッチクラフト・コラボレーション
--Witchcrafter Collaboration
--Scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Add this card to the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_WITCHCRAFTER),tp,LOCATION_MZONE,0,1,nil) end)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_WITCHCRAFTER}
function s.tgfilter(c)
	return c:IsSetCard(SET_WITCHCRAFTER) and c:IsFaceup() and not c:HasFlagEffect(id)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	if chk==0 then return (Duel.IsAbleToEnterBP() or (Duel.IsBattlePhase() and not Duel.IsPhase(PHASE_BATTLE)))
		and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local c=e:GetHandler()
		tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
		--It can make a second attack during each Battle Phase this turn
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		--If it attacks this turn your opponent cannot activate Spell/Trap Cards until the end of the Damage Step
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EVENT_ATTACK_ANNOUNCE)
		e2:SetOperation(s.limop)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e2)
	end
end
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	--Your opponent cannot activate Spell/Trap Cards until the end of the Damage Step
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(function(e,re,tp) return re:IsHasType(EFFECT_TYPE_ACTIVATE) end)
	e1:SetReset(RESET_PHASE|PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end