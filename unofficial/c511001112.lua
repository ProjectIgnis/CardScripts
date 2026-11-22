--機械じかけのマジックミラー (Anime)
--Magical Trick Mirror (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) end)
	e1:SetTarget(s.actg)
	e1:SetOperation(s.acop)
	c:RegisterEffect(e1)
end
function s.acfilter(c,tp,szone_adjustment)
	if not c:IsSpell() or c:IsForbidden() then return false end
	local te=c:GetActivateEffect()
	--Check for HOPT
	if not (te and te:CheckCountLimit(tp)) then return false end
	--Check for "cannot activate" restrictions
	if c:IsHasEffect(EFFECT_CANNOT_TRIGGER) then return false end
	local cannot_act_restrictions={Duel.GetPlayerEffect(tp,EFFECT_CANNOT_ACTIVATE)}
	if cannot_act_restrictions[1] then
		for _,eff in ipairs(cannot_act_restrictions) do
			local eff_value=eff:GetValue()
			if type(eff_value)~='function' or eff_value(eff,te,tp) then return false end
		end
	end
	local te_effect_code=te:GetCode()
	local res,ceg,cep,cev,cre,cr,crp=Duel.CheckEvent(te_effect_code,true)
	if not res and te_effect_code~=EVENT_FREE_CHAIN then return false end
	local condition=te:GetCondition()
	local cost=te:GetCost()
	local target=te:GetTarget()
	--Check if the card can be activated
	if condition and not condition(te,tp,ceg,cep,cev,cre,cr,crp) then return false end
	if cost and not cost(te,tp,ceg,cep,cev,cre,cr,crp,0) then return false end
	if target and not target(te,tp,ceg,cep,cev,cre,cr,crp,0) then return false end
	--Don't need to check for zones for a Field Card
	if c:IsType(TYPE_FIELD) then return true end
	--Check for cards that can only be activated in certain zones
	local zones=0xff
	if te:IsHasProperty(EFFECT_FLAG_LIMIT_ZONE) then
		zones=te:GetValue()(te,tp,eg,ep,ev,re,r,rp)
	end
	return Duel.GetLocationCount(tp,LOCATION_SZONE,tp,LOCATION_REASON_TOFIELD,zones)-szone_adjustment>0
end
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local szone_adjustment=c:IsLocation(LOCATION_SZONE) and 0 or 1
	if chk==0 then return Duel.IsExistingMatchingCard(s.acfilter,tp,0,LOCATION_GRAVE,1,nil,tp,szone_adjustment) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,1-tp,0)
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.acfilter),tp,0,LOCATION_GRAVE,nil,tp,0)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
	local sc=g:Select(tp,1,1,nil):GetFirst()
	local te=sc:GetActivateEffect()
	if not te then return end
	
	local location=sc:IsType(TYPE_FIELD) and LOCATION_FZONE or LOCATION_SZONE
	--Adjust "zones" for cards that can only be activated in certain zones
	local zones=0xff
	if te:IsHasProperty(EFFECT_FLAG_LIMIT_ZONE) then
		zones=te:GetValue()(te,tp,eg,ep,ev,re,r,rp)
	end
	if not Duel.MoveToField(sc,tp,tp,location,POS_FACEUP,true,zones) then return end
	--Set activated status, show the card, create relation to itself, and use the effect's count limit (if any)
	sc:SetStatus(STATUS_ACTIVATED,true)
	Duel.Hint(HINT_CARD,0,sc:GetCode())
	sc:CreateEffectRelation(te)
	te:UseCountLimit(tp)
	--Mark the card as "to be sent to the GY" if it's not a card that remains on the field after activation
	if not (sc:IsType(TYPE_FIELD) or sc:IsEquipSpell() or sc:IsContinuousSpellTrap() or sc:IsLinkSpell()
		or sc:IsHasEffect(EFFECT_REMAIN_FIELD) or te:GetCost()==aux.RemainFieldCost) then
		sc:CancelToGrave(false)
	end
	local te_effect_code=te:GetCode()
	local ceg,cep,cev,cre,cr,crp=Duel.CheckEvent(te_effect_code,true)
	--Execute the cost, target, and operation with the designated parameters if the card's effects after it's placed on the field aren't negated
	if not sc:IsDisabled() then
		local cost=te:GetCost()
		local target=te:GetTarget()
		local operation=te:GetOperation()
		--Set the effect's property so that targeted cards are highlighted normally
		e:SetProperty(te:GetProperty())
		--Activation procedure
		if cost then cost(te,tp,ceg,cep,cev,cre,cr,crp,1) end
		if target then target(te,tp,ceg,cep,cev,cre,cr,crp,1) end
		--Manually create the effect relation for any targeted cards
		local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		if tg then
			for tc in tg:Iter() do
				tc:CreateEffectRelation(te)
			end
		end
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		local field_event_eg=Group.FromCards(sc)
		local current_chain_link=Duel.GetCurrentChain()
		--Manually raise the events for activating it
		Duel.RaiseSingleEvent(sc,EVENT_CHAINING,te,0,tp,tp,current_chain_link)
		Duel.RaiseEvent(field_event_eg,EVENT_CHAINING,te,0,tp,tp,current_chain_link)
		--Break to separate the activation and the resolution
		Duel.BreakEffect()
		--Manually raise the events for the start of resolution
		Duel.RaiseSingleEvent(sc,EVENT_CHAIN_SOLVING,te,0,tp,tp,current_chain_link)
		Duel.RaiseEvent(field_event_eg,EVENT_CHAIN_SOLVING,te,0,tp,tp,current_chain_link)
		--Resolution of the effect
		if operation then operation(te,tp,ceg,cep,cev,cre,cr,crp) end
		--Manually raise the events for the end of resolution
		Duel.RaiseSingleEvent(sc,EVENT_CHAIN_SOLVED,te,0,tp,tp,current_chain_link)
		Duel.RaiseEvent(field_event_eg,EVENT_CHAIN_SOLVED,te,0,tp,tp,current_chain_link)
	end
	--Manually release the effect relation for this card and any targeted cards
	sc:ReleaseEffectRelation(te)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if tg then
		for tc in tg:Iter() do
			tc:ReleaseEffectRelation(te)
		end
	end
end
