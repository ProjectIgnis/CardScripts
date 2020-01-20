--E・HERO カオス・ネオス
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_NEOS,43237273,17732278)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	aux.EnableNeosReturn(c,nil,nil,s.retop)
	--coin
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_COIN+CATEGORY_DESTROY+CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(s.coincon)
	e5:SetTarget(s.cointg)
	e5:SetOperation(s.coinop)
	c:RegisterEffect(e5)
end
s.listed_names={CARD_NEOS}
s.material_setcode={0x8,0x3008,0x9,0x1f}
s.toss_coin=true
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_ONFIELD,0,nil)
end
function s.contactop(g,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoDeck(g,nil,2,REASON_COST+REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
end
function s.coincon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,3)
end
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local c1,c2,c3=Duel.TossCoin(tp,3)
	if c1+c2+c3==3 then
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		Duel.Destroy(g,REASON_EFFECT)
	elseif c1+c2+c3==2 then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		local c=e:GetHandler()
		local tc=g:GetFirst()
		for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	elseif c1+c2+c3==1 then
		local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,0,nil)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
