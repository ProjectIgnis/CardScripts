--鉄獣の撃鉄
--Tri-Brigade Hammer
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects (but you can only use each effect of "Tri-Brigade Hammer" once per turn)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMING_BATTLE_START|TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_names={id}
s.listed_series={SET_TRI_BRIGADE}
function s.thfilter(c)
	return c:IsSetCard(SET_TRI_BRIGADE) and c:IsSpellTrap() and not c:IsCode(id) and c:IsAbleToHand()
end
function s.spcostfilter(c)
	return c:IsSetCard(SET_TRI_BRIGADE) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true,false)
end
function s.spfilter(c,e,tp,g,link)
	return c:IsSetCard(SET_TRI_BRIGADE) and c:IsLinkMonster() and (not link or c:IsLink(link))
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		and Duel.GetLocationCountFromEx(tp,tp,g,c)>0
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=not Duel.HasFlagEffect(tp,id)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local rg=Duel.GetMatchingGroup(s.spcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	local lg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,g)
	local _,min_link=lg:GetMinGroup(Card.GetLink)
	local b2=not Duel.HasFlagEffect(tp,id+100) and min_link and min_link<=#rg
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE|PHASE_END,0,1)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		local link_map={}
		for lc in lg:Iter() do
			link_map[lc:GetLink()]=true
		end
		local rescon=function(sg) return link_map[#sg] end
		local sg=aux.SelectUnselectGroup(rg,e,tp,min_link,#rg,rescon,1,tp,HINTMSG_REMOVE,rescon)
		Duel.Remove(sg,POS_FACEUP,REASON_COST)
		e:SetLabel(op,#sg)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op,link=e:GetLabel()
	if op==1 then
		--Add 1 "Tri-Brigade" Spell/Trap from your Deck to your hand, except "Tri-Brigade Hammer"
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	elseif op==2 and link then
		--Special Summon 1 "Tri-Brigade" Link Monster from your Extra Deck, with Link Rating equal to the number banished, ignoring its Summoning conditions
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil,link)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
		local c=e:GetHandler()
		--You cannot Special Summon from the Extra Deck for the rest of this turn, except Beast, Beast-Warrior, or Winged Beast monsters
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,3))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACES_BEAST_BWARRIOR_WINGB) end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		--"Clock Lizard" check
		aux.addTempLizardCheck(c,tp,function(e,c) return not c:IsOriginalRace(RACES_BEAST_BWARRIOR_WINGB) end)
	end
end