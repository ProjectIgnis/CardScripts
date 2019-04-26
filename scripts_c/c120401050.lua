--ルーラー・オブ・ダンジョンズ
--Ruler of the Dungeons
--Scripted by Eerie Code
function c120401050.initial_effect(c)
	--tohand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(120401050,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c120401050.thtg)
	e1:SetOperation(c120401050.thop)
	c:RegisterEffect(e1)
	--spsummon proc
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,120401050)
	e2:SetCondition(c120401050.spcon)
	e2:SetOperation(c120401050.spop)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(120401050,0))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,120401050+100)
	e3:SetCost(c120401050.thcost2)
	e3:SetTarget(c120401050.thtg2)
	e3:SetOperation(c120401050.thop2)
	c:RegisterEffect(e3)
	--trap monster support
	if not Card.IsTrapMonster then
		function Card.IsTrapMonster(c)
			return c:IsCode(3129635,4904633,8522996,13955608,20960340,21843307,23626223,26905245,27062594,28649820,42237854,43959432,49514333,50277973,54241725,54297661,60433216,70406920,79852326,87772572,90440725,92092092,92099232,97232518) or c.trap_monster
		end
	end
end
function c120401050.thfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
function c120401050.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c120401050.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c120401050.thfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,c120401050.thfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c120401050.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	if tc:IsRelateToEffect(e) and tc:IsFaceup() 
		and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND)
		and g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg=g:Select(tp,1,1,nil)
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
function c120401050.spfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsAbleToGraveAsCost()
end
function c120401050.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local loc=LOCATION_ONFIELD
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then loc=LOCATION_MZONE end
	return Duel.IsExistingMatchingCard(c120401050.spfilter,tp,loc,0,1,nil)
end
function c120401050.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local loc=LOCATION_ONFIELD
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then loc=LOCATION_MZONE end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c120401050.spfilter,tp,loc,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function c120401050.thcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function c120401050.thfilter2(c)
	return c:IsType(TYPE_CONTINUOUS) and c:IsType(TYPE_TRAP)
		and c:IsTrapMonster() and c:IsAbleToHand()
end
function c120401050.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c120401050.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c120401050.thop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c120401050.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
