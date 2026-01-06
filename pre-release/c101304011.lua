--獄神影獣－ネルヴェド
--Power Patron Shadow Beast Nervedo
--scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--When a monster effect activated by your opponent in response to the activation of your "Power Patron" or "Artmage" monster's effect resolves, you can negate that effect, then destroy this card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(s.discon)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--You can banish (face-down) the top 3 cards of your Deck; destroy this card, and if you do, Special Summon 1 "Nerva the Power Patron of Creation" from your Extra Deck (this is treated as a Fusion Summon)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--If this card is added to your Extra Deck face-up: You can Special Summon 1 "Power Patron" or "Artmage" monster from your Deck or face-up Extra Deck, except "Power Patron Shadow Beast Nervedo"
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_DECK)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_names={id,53589300} --"Nerva the Power Patron of Creation"
s.listed_series={SET_POWER_PATRON,SET_ARTMAGE}
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local ch=Duel.GetCurrentChain()-1
	if not (ch>0 and ep==1-tp and re:IsMonsterEffect() and Duel.IsChainDisablable(ev) and not Duel.HasFlagEffect(tp,id)) then return false end
	local ctrl,setcodes,trig_eff=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_SETCODES,CHAININFO_TRIGGERING_EFFECT)
	if ctrl~=tp or not trig_eff:IsMonsterEffect() then return false end
	for _,set in ipairs(setcodes) do
		if (SET_POWER_PATRON&0xfff)==(set&0xfff) and (SET_POWER_PATRON&set)==SET_POWER_PATRON then return true end
		if (SET_ARTMAGE&0xfff)==(set&0xfff) and (SET_ARTMAGE&set)==SET_ARTMAGE then return true end
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,2)) then return end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	Duel.Hint(HINT_CARD,0,id)
	if Duel.NegateEffect(ev) then
		Duel.BreakEffect()
		Duel.Destroy(c,REASON_EFFECT)
	end
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetDecktopGroup(tp,3)
	if chk==0 then return g:IsExists(Card.IsAbleToRemoveAsCost,3,nil,POS_FACEDOWN) end
	Duel.DisableShuffleCheck()
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
function s.nervaspfilter(c,e,tp,hc)
	return c:IsCode(53589300) and Duel.GetLocationCountFromEx(tp,tp,hc,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.nervaspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.nervaspfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if not sc then return end
	sc:SetMaterial(nil)
	if Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)>0 then
		sc:CompleteProcedure()
	end
end
function s.spcon(e)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA) and c:IsFaceup()
end
function s.spfilter(c,e,tp)
	if not c:IsSetCard({SET_POWER_PATRON,SET_ARTMAGE}) or c:IsCode(id) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	if c:IsLocation(LOCATION_DECK) then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	else
		return c:IsFaceup() and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end