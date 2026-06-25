--疾風の豹戦士パンサーウォリアー
--Swift Panther Warrior
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--During the Main Phase (Quick Effect): You can Tribute 1 other monster from your hand or field, then activate 1 of these effects;
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetCost(s.effcost)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e1)
	--Cannot declare an attack unless a monster(s) was Tributed this turn
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function() return not Duel.HasFlagEffect(0,id) end)
	c:RegisterEffect(e2)
	--Keep track of a monster being Tributed
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_RELEASE)
		ge1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			if not Duel.HasFlagEffect(0,id) and eg:IsExists(function(c) return c:IsPreviousLocation(LOCATION_MZONE) or (not c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsMonsterCard()) end,1,nil) then
				Duel.RegisterFlagEffect(0,id,RESET_PHASE|PHASE_END,0,1)
			end
		end)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_names={CARD_DARK_TIME_WIZARD,id}
function s.spcostfilter(c,e,tp)
	return Duel.GetMZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,c,e,tp)
end
function s.spfilter(c,e,tp)
	return c:ListsCode(CARD_DARK_TIME_WIZARD) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tgfilter(c)
	return c:IsSpellTrap() and c:ListsCode(CARD_DARK_TIME_WIZARD) and c:IsAbleToGrave()
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	--● Special Summon 1 monster that mentions "Dark Time Wizard" from your hand or Deck, except "Swift Panther Warrior"
	local b1=Duel.CheckReleaseGroupCost(tp,s.spcostfilter,1,true,nil,c,e,tp)
	--● Send 1 Spell/Trap that mentions "Dark Time Wizard" from your Deck to the GY
	local b2=Duel.CheckReleaseGroupCost(tp,nil,1,true,nil,c)
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	local filter_func=not b2 and s.spcostfilter or nil
	local g=Duel.SelectReleaseGroupCost(tp,filter_func,1,1,true,nil,c,e,tp)
	Duel.Release(g,REASON_COST)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	--● Special Summon 1 monster that mentions "Dark Time Wizard" from your hand or Deck, except "Swift Panther Warrior"
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp)
	--● Send 1 Spell/Trap that mentions "Dark Time Wizard" from your Deck to the GY
	local b2=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOGRAVE)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--● Special Summon 1 monster that mentions "Dark Time Wizard" from your hand or Deck, except "Swift Panther Warrior"
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif op==2 then
		--● Send 1 Spell/Trap that mentions "Dark Time Wizard" from your Deck to the GY
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end