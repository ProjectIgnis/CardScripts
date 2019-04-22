--Tinsight Assembly Line
--AlphaKretin
function c210310208.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,4034+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c210310208.target)
	e1:SetOperation(c210310208.activate)
	c:RegisterEffect(e1)
	--Revived monsters indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c210310208.indestg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Effect on summon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1)
	e3:SetCondition(c210310208.effcon)
	e3:SetTarget(c210310208.postg)
	e3:SetOperation(c210310208.posop)
	e3:SetLabel(TYPE_FUSION)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetTarget(c210310208.atktg)
	e4:SetOperation(c210310208.atkop)
	e4:SetLabel(TYPE_SYNCHRO)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCategory(0)
	e5:SetTarget(c210310208.atttg)
	e5:SetOperation(c210310208.attop)
	e5:SetLabel(TYPE_XYZ)
	c:RegisterEffect(e5)
	local e6=e3:Clone()
	e6:SetCategory(0)
	e6:SetTarget(c210310208.mvtg)
	e6:SetOperation(c210310208.mvop)
	e6:SetLabel(TYPE_LINK)
	c:RegisterEffect(e6)

end
function c210310208.filter(c)
	return c:IsSetCard(0xf35) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c210310208.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210310208.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c210310208.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c210310208.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c210310208.indestg(e,c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsPreviousLocation(LOCATION_GRAVE) and c:IsSetCard(0x1f35)
end
function c210310208.effcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()==1 and eg:GetFirst():IsType(e:GetLabel()) and eg:GetFirst():IsSetCard(0x2f35)
end
function c210310208.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsDefensePos() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
function c210310208.posop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or not Duel.IsExistingMatchingCard(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local tc=Duel.SelectMatchingCard(tp,Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.ChangePosition(tc,0,0,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
end
function c210310208.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsFaceup() and chkc:IsControler(1-tp) and chkc:GetLocation()==LOCATION_MZONE end
	if chk==0 then return Duel.IsExistingMatchingCard(aux.nzatk,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
function c210310208.atkop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or not Duel.IsExistingMatchingCard(aux.nzatk,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then return end
	local tc=Duel.SelectMatchingCard(tp,aux.nzatk,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetReset(RESET_EVENT+0x1fe0000)
	e1:SetValue(0)
	tc:GetFirst():RegisterEffect(e1)
end
function c210310208.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_GRAVE,0,1,nil) end
end
function c210310208.attop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_GRAVE,0,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local og=g:Select(tp,1,1,nil)
		Duel.Overlay(tc,og)
	end
end
--credit to andre for this function
function c210310208.zonechk(zone,tp)
	local val=0
	for i=0,4 do
		if bit.band(bit.lshift(0x10000,i),zone)>0 and not Duel.GetFieldCard(1-tp,LOCATION_MZONE,i) then val=val+1 end
	end
	return val>0
end
function c210310208.mvfilter(c,lc)
	return not lc:GetLinkedGroup():IsContains(c)
end
function c210310208.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=eg:GetFirst()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and not chkc:IsControler(tp) and c210310208.mvfilter(chkc,c) end
	if chk==0 then return Duel.IsExistingMatchingCard(c210310208.mvfilter,tp,0,LOCATION_MZONE,1,nil,c) and c210310208.zonechk(c:GetLinkedZone(),tp) end
end
function c210310208.mvop(e,tp,eg,ep,ev,re,r,rp)
	local c=eg:GetFirst()
	if not e:GetHandler():IsRelateToEffect(e) or not Duel.IsExistingMatchingCard(c210310208.mvfilter,tp,0,LOCATION_MZONE,1,nil,c) then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(63394872,1))
	local tc=Duel.SelectMatchingCard(tp,c210310208.mvfilter,tp,0,LOCATION_MZONE,1,1,nil,c)
	Duel.Hint(HINT_SELECTMSG,tp,571)
	if c210310208.zonechk(c:GetLinkedZone(),tp) then
        	local s=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,0x1f0000-c:GetLinkedZone())
        	local nseq=0
        	for i=0,4 do
            		if bit.band(bit.lshift(0x10000,i),s)==bit.lshift(0x10000,i) then
                		nseq=i
                		break
            		end
        	end
        	Duel.MoveSequence(tc:GetFirst(),nseq)
	end
end

