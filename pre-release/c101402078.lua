--祟リ紙ノ報イ
--Cursed Paper Retribution
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Target 1 monster you control and 1 face-up card your opponent controls; destroy your monster, and if you do, negate the effects of that opponent's card until the end of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--If this Set card is sent to the GY: You can target 1 face-up card your opponent controls; negate its effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.negatecon)
	e2:SetTarget(s.negatetg)
	e2:SetOperation(s.negateop)
	c:RegisterEffect(e2)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetTargetGroup(nil,tp,LOCATION_MZONE,0,nil)+Duel.GetTargetGroup(Card.IsNegatable,tp,0,LOCATION_ONFIELD,nil)
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetControler),1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(tg)
	local group_to_destroy,group_to_negate=tg:Split(Card.IsControler,nil,tp)
	e:GetChainData().group_to_destroy=group_to_destroy
	e:GetChainData().group_to_negate=group_to_negate
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,group_to_destroy,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,group_to_negate,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==0 then return end
	local destroy_tc=(tg&(e:GetChainData().group_to_destroy)):GetFirst()
	local negate_tc=(tg&(e:GetChainData().group_to_negate)):GetFirst()
	if destroy_tc and destroy_tc:IsControler(tp) and Duel.Destroy(destroy_tc,REASON_EFFECT)>0
		and negate_tc and negate_tc:IsControler(1-tp) and negate_tc:IsNegatable() then
		--Negate the effects of that opponent's card until the end of this turn
		negate_tc:NegateEffects(e:GetHandler(),RESET_PHASE|PHASE_END,true)
	end
end
function s.negatecon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
function s.negatetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsNegatable() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,tp,0)
end
function s.negateop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		--Negate its effects
		tc:NegateEffects(e:GetHandler(),nil,true)
	end
end