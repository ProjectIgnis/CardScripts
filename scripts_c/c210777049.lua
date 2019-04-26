--Solar Eclipse Dragon Inti
--scripted by Naim
local cardID = c210777049
function c210777049.initial_effect(c)
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
	--effect indest
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(210777049,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(cardID.limcon)
	e3:SetTarget(cardID.tg)
	e3:SetOperation(cardID.op)
	c:RegisterEffect(e3)
	--destroy
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(210777049,1))
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DESTROYED)
	e4:SetTarget(cardID.sptg)
	e4:SetOperation(cardID.ssop)
	c:RegisterEffect(e4)
	--spsummon next phase
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetOperation(cardID.spreg)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(210777049,0))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e6:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e6:SetCondition(cardID.spcon)
	e6:SetCountLimit(1)
	e6:SetTarget(cardID.sptg2)
	e6:SetOperation(cardID.spop)
	e6:SetLabelObject(e5)
	c:RegisterEffect(e6)
end
function cardID.limcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function cardID.filter1(c)
	return c:IsAbleToHand() and (c:IsCode(78552773) or c:IsCode(42280216))
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
	return c:IsCode(66818682) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cardID.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_R,nil,0,1-tp,0)
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
		Duel.Damage(1-tp,dam/2,REASON_EFFECT)
	end
end
function cardID.spreg(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		e:SetLabel(Duel.GetTurnCount())
		c:RegisterFlagEffect(210777049,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_STANDBY,0,2)
	else
		e:SetLabel(0)
		c:RegisterFlagEffect(210777049,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_STANDBY,0,1)
	end
end
function cardID.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(210777049)>0
end
function cardID.spfilter2(c,e,tp)
	return c:IsCode(66818682) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cardID.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cardID.spfilter2,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
	c:ResetFlagEffect(210777049)
end
function cardID.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cardID.spfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp)
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