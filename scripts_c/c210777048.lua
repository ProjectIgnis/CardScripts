--Lunar Eclipse Dragon Quilla
--scripted by Naim
local cardID = c210777048
function cardID.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,nil,1,1,aux.NonTunerEx(Card.IsType,TYPE_SYNCHRO),1,99)
	c:EnableReviveLimit()
	--code
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(66818682)
	c:RegisterEffect(e1)
	--battle indest
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(210777048,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(cardID.limcon)
	e3:SetTarget(cardID.tg)
	e3:SetOperation(cardID.op)
	c:RegisterEffect(e3)
	--destroy
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(210777048,1))
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetTarget(cardID.sptg)
	e4:SetOperation(cardID.ssop)
	c:RegisterEffect(e4)
end
function cardID.limcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function cardID.filter1(c)
	return c:IsAbleToHand() and (c:IsCode(42280216) or c:IsCode(78275321))
end
function cardID.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cardID.filter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function cardID.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cardID.filter1),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function cardID.spfilter(c,e,tp)
	return c:IsCode(39823987) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cardID.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and Duel.IsExistingMatchingCard(cardID.spfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp)
	then Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE) end
end
function cardID.ssop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if Duel.Destroy(g,REASON_EFFECT) then
		local dg=Duel.GetOperatedGroup()
		local tc=dg:GetFirst()
		local dam=0
		while tc do
			local atk=tc:GetTextAttack()
			if atk<0 then atk=0 end
			dam=dam+atk
			tc=dg:GetNext()
		end
			if dam>0 then
			Duel.Recover(tp,dam/2,REASON_EFFECT)
				if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cardID.spfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp)
				local tc=g:GetFirst()
				if tc then
					if tc:GetLocation(LOCATION_EXTRA) then
					Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
					tc:CompleteProcedure()
						else
					Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
					end
				end	
			end
	end
end