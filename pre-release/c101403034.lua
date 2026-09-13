--白鴉の森の女主人ディアベルゼ
--Diabellze the Mistress of the White Crow Forest
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 1 Fusion or Synchro Monster + 1 Spellcaster or Illusion monster
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsType,TYPE_FUSION|TYPE_SYNCHRO),aux.FilterBoolFunctionEx(Card.IsRace,RACE_SPELLCASTER|RACE_ILLUSION))
	--If this card is Special Summoned: You can place any number of monsters you control face-up in their owners' Spell & Trap Zones as Continuous Spells, then you can return cards on the field to the hand up to the number of Spells/Traps you control. You can only use this effect of "Diabellze the Mistress of the White Crow Forest" once per turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.pltg)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)
	--Gains 700 ATK/DEF for each Spell/Trap on the field
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_SINGLE)
	e2a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2a:SetCode(EFFECT_UPDATE_ATTACK)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetValue(function(e,c)
		return 700*Duel.GetMatchingGroupCount(Card.IsSpellTrap,0,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	end)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2b)
	--This face-up Fusion Summoned card cannot be used as Fusion Material
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(function(e)
		return e:GetHandler():IsFusionSummoned()
	end)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
s.miracle_synchro_fusion=true
function s.plfilter(c)
	local owner=c:GetOwner()
	return Duel.GetLocationCount(owner,LOCATION_SZONE)>0 and c:CheckUniqueOnField(owner) and not c:IsForbidden()
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.rescon(your_max_selection,opp_max_selection)
	return function(sg,e,tp,mg)
		local your_g,opp_g=sg:Split(Card.IsOwner,nil,tp)
		return #your_g<=your_max_selection and #opp_g<=opp_max_selection,#your_g>your_max_selection or #opp_g>opp_max_selection
	end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.plfilter,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	local your_monsters,opp_monsters=g:Split(Card.IsOwner,nil,tp)
	local your_max_selection=Duel.GetLocationCount(tp,LOCATION_SZONE)
	your_max_selection=math.min(#your_monsters,your_max_selection)
	local opp_max_selection=Duel.GetLocationCount(1-tp,LOCATION_SZONE)
	opp_max_selection=math.min(#opp_monsters,opp_max_selection)
	local total_max_count=math.min(#g,your_max_selection+opp_max_selection)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,total_max_count,s.rescon(your_max_selection,opp_max_selection),1,tp,HINTMSG_TOFIELD)
	if #sg==0 then return end
	Duel.HintSelection(sg)
	local success=false
	local c=e:GetHandler()
	for tc in sg:Iter() do
		if not tc:IsImmuneToEffect(e) and Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,tc:IsMonsterCard()) then
			success=true
			--Treat it as a Continuous Spell
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
			e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
			tc:RegisterEffect(e1)
		end
	end
	if success and Duel.IsExistingMatchingCard(Card.IsSpellTrap,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local maxct=Duel.GetMatchingGroupCount(Card.IsSpellTrap,tp,LOCATION_ONFIELD,0,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local rthg=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,maxct,nil)
		if #rthg>0 then
			Duel.HintSelection(rthg)
			Duel.BreakEffect()
			Duel.SendtoHand(rthg,nil,REASON_EFFECT)
		end
	end
end