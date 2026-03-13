--カオスシルクハット
--Chaos Hats
--scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--When your opponent activates a monster effect, or a Normal Spell/Trap Card: Choose 3 Spells/Traps with different names from each other from your Deck and 1 monster in your Main Monster Zone that mentions "Ritual of Light and Darkness". Special Summon the chosen Spells/Traps in face-down Defense Position as Normal Monsters (Spellcaster/DARK/Level 8/ATK 0/DEF 0) and their names become "Chaos Hats" (even while face-down), Set the chosen monster, and shuffle them on the field, then your opponent's activated effect becomes "Destroy 1 face-down Defense Position monster your opponent controls"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION+CATEGORY_SET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_RITUAL_OF_LIGHT_AND_DARKNESS,id}
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and (re:IsMonsterEffect() or (re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsNormalSpellTrap()))
end
function s.setfilter(c)
	return c:ListsCode(CARD_RITUAL_OF_LIGHT_AND_DARKNESS) and c:IsCanTurnSet()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,LOCATION_DECK,0,nil)
		return aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,0)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>=3
			and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
			and Duel.IsPlayerCanSpecialSummonMonster(tp,id,nil,TYPE_MONSTER|TYPE_NORMAL,0,0,8,RACE_SPELLCASTER,ATTRIBUTE_DARK,POS_FACEDOWN_DEFENSE)
			and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_MMZONE,0,1,nil)
	end
	--Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp,LOCATION_MZONE)<3 then return end
	local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,LOCATION_DECK,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
	if #sg~=3 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local mc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_MMZONE,0,1,1,nil):GetFirst()
	if not mc or mc:IsImmuneToEffect(e) then return end
	Duel.HintSelection(mc)
	for sc in sg:Iter() do
		--Special Summon the chosen Spells/Traps in face-down Defense Position as Normal Monsters (Spellcaster/DARK/Level 8/ATK 0/DEF 0) and their names become "Chaos Hats" (even while face-down)
		local e1=Effect.CreateEffect(sc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetValue(TYPE_NORMAL|TYPE_MONSTER)
		e1:SetReset(RESET_EVENT|RESET_TOGRAVE|RESET_REMOVE|RESET_TEMP_REMOVE|RESET_TOHAND|RESET_TODECK|RESET_OVERLAY)
		sc:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RACE)
		e2:SetValue(RACE_SPELLCASTER)
		sc:RegisterEffect(e2,true)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e3:SetValue(ATTRIBUTE_DARK)
		sc:RegisterEffect(e3,true)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CHANGE_LEVEL)
		e4:SetValue(8)
		sc:RegisterEffect(e4,true)
		local e5=e1:Clone()
		e5:SetCode(EFFECT_SET_BASE_ATTACK)
		e5:SetValue(0)
		sc:RegisterEffect(e5,true)
		local e6=e1:Clone()
		e6:SetCode(EFFECT_SET_BASE_DEFENSE)
		e6:SetValue(0)
		sc:RegisterEffect(e6,true)
		local e7=e1:Clone()
		e7:SetCode(EFFECT_CHANGE_CODE)
		e7:SetValue(id)
		sc:RegisterEffect(e7,true)
	end
	Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEDOWN_DEFENSE)
	Duel.ConfirmCards(1-tp,sg)
	if mc:IsHasEffect(EFFECT_LIGHT_OF_INTERVENTION) then
		Duel.ChangePosition(mc,POS_FACEUP_DEFENSE)
	else
		Duel.ChangePosition(mc,POS_FACEDOWN_DEFENSE)
		mc:ClearEffectRelation()
	end
	sg:AddCard(mc)
	Duel.ShuffleSetCard(sg)
	--Your opponent's activated effect becomes "Destroy 1 face-down Defense Position monster your opponent controls"
	Duel.BreakEffect()
	local tg=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,tg)
	Duel.ChangeChainOperation(ev,s.repop)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end