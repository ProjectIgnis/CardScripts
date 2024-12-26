--創星竜華－光巴
--Sosei Ryu-Ge Mistva
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Pendulum Summon procedure
	Pendulum.AddProcedure(c)
	--Must be Special Summoned by its own effect
	c:AddMustBeSpecialSummoned()
	--You can only Special Summon "Sosei Ryu-Ge Mistva(s)" once per turn
	c:SetSPSummonOnce(id)
	--Add 1 "Ryu-Ge" card from your Deck to your hand, except a Pendulum Monster, then destroy this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Tribute 1 Level 10 "Ryu-Ge" monster, and if you do, Special Summon this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_RYU_GE}
s.listed_names={id}
function s.thfilter(c)
	return c:IsSetCard(SET_RYU_GE) and not c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) then return end
		Duel.BreakEffect()
		Duel.Destroy(c,REASON_EFFECT)
	end
end
function s.spconfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_BATTLE|REASON_EFFECT)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.spconfilter,1,nil)
end
function s.tributefilter(c,e,tp,hc)
	return c:IsLevel(10) and c:IsSetCard(SET_RYU_GE) and c:IsReleasableByEffect()
		and Duel.GetLocationCountFromEx(tp,tp,c,hc)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.tributefilter,tp,LOCATION_MZONE,0,1,nil,e,tp,c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,true) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_ONFIELD)
end
function s.plfilter(c)
	return c:IsSetCard(SET_RYU_GE) and c:IsContinuousSpell() and not c:IsForbidden()
end
function s.tfcheck(sg,e,tp)
	return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 or sg:IsExists(Card.IsLocation,1,nil,LOCATION_STZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local rg=Duel.SelectMatchingCard(tp,s.tributefilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,c)
	if #rg==0 or Duel.Release(rg,REASON_EFFECT)==0 then return end
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,SUMMON_TYPE_RITUAL,tp,tp,true,true,POS_FACEUP)>0 then
		c:CompleteProcedure()
		local fg=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
		local dg=Duel.GetMatchingGroup(s.plfilter,tp,LOCATION_DECK,0,nil)
		if #fg>0 and #dg>0 and aux.SelectUnselectGroup(fg,e,tp,1,2,s.tfcheck,0) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			local desg=aux.SelectUnselectGroup(fg,e,tp,1,2,s.tfcheck,1,tp,HINTMSG_DESTROY,s.tfcheck)
			Duel.HintSelection(desg)
			Duel.BreakEffect()
			local ct=Duel.Destroy(desg,REASON_EFFECT)
			local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
			ct=math.min(ct,ft)
			if ct==0 then return end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local placeg=dg:Select(tp,1,ct,nil)
			for tc in placeg:Iter() do
				Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			end
		end
	end
end