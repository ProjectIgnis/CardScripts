--Dark Magic Karma
--scripted by Larry126
function c210002503.initial_effect(c)
	c:SetUniqueOnField(1,0,210002503)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,210002503)
	e1:SetTarget(c210002503.target)
	e1:SetOperation(c210002503.activate)
	c:RegisterEffect(e1)
	--atk boost
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c210002503.atktg)
	e2:SetValue(c210002503.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
c210002503.listed_names={46986414,210002503,0xa1}
function c210002503.atktg(e,c)
	return c:IsFaceup() and (c:IsSetCard(0x10a2) or (c:IsRace(RACE_SPELLCASTER) and (c:IsLevelAbove(6) or c:IsRankAbove(6))))
end
function c210002503.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil)*200
end
function c210002503.filter(c)
	return aux.IsCodeListed(c,46986414) and c:IsType(TYPE_SPELL+TYPE_TRAP)
		and c:IsSSetable() and not c:IsCode(210002503)
end
function c210002503.cfilter(c,g)
	for tc in aux.Next(g) do
		if c:IsCode(tc:GetCode()) then
			return false
		end
	end
	return true
end
function c210002503.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local rt=Duel.GetMatchingGroup(c210002503.filter,tp,LOCATION_DECK,0,nil):GetClassCount(Card.GetCode)
	local ck=Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
		and math.min(ft,rt)>0
	if ck and Duel.SelectYesNo(tp,94) then
		local ct=Duel.DiscardHand(tp,Card.IsDiscardable,1,math.min(ft,rt),REASON_COST)
		e:SetLabel(ct)
	end
end
function c210002503.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local ct=e:GetLabel()
	local g=Duel.GetMatchingGroup(c210002503.filter,tp,LOCATION_DECK,0,nil)
	if ct==nil or math.min(Duel.GetLocationCount(tp,LOCATION_SZONE),g:GetClassCount(Card.GetCode))<ct then return end
	local tg=Group.CreateGroup()
	while tg:GetCount()<ct do
		local cancel=tg:GetCount()>0
		local cg=g
		if tg:GetCount()>0 then
			cg=g:Filter(c210002503.cfilter,nil,tg)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local tc=Group.SelectUnselect(cg,tg,tp,cancel,cancel,ct,ct)
		if not tc then break end
		if not tg:IsContains(tc) then
			tg:AddCard(tc)
		else
			tg:RemoveCard(tc)
		end
	end
	if tg:GetCount()==0 then return end
	Duel.SSet(tp,tg)
	Duel.ConfirmCards(1-tp,tg)
	for tc in aux.Next(tg) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1)
	end
end