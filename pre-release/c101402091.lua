--JP Name
--Angelechy Seneschal
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner + 1+ non-Tuners
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--If this card is Special Summoned: Activate this effect; each player can Special Summon 1 Fairy Synchro Monster from their Extra Deck (but negate its effects), also this card, and monsters Special Summoned by this effect, cannot be used as material for an Xyz or Link Summon, and return them to the Extra Deck when they leave the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE+CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--If an "Angelechy" monster targets this card for an attack: Negate that attack, and if you do, give control of this card to your opponent
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ANGELECHY}
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_EITHER,LOCATION_EXTRA)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_FAIRY) and c:IsSynchroMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local turn_player=Duel.GetTurnPlayer()
	for player=turn_player,1-turn_player,(-1)^turn_player do
		local g=Duel.GetMatchingGroup(s.spfilter,player,LOCATION_EXTRA,0,nil,e,player)
		if #g>0 and Duel.SelectYesNo(player,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,player,HINTMSG_SPSUMMON)
			local sc=g:Select(player,1,1,nil):GetFirst()
			if sc and Duel.SpecialSummonStep(sc,0,player,player,false,false,POS_FACEUP) then
				--Negate its effects
				sc:NegateEffects(c)
				s.applyrestrictions(sc,c)
			end
		end
	end
	Duel.SpecialSummonComplete()
	if c:IsRelateToEffect(e) then
		s.applyrestrictions(c,c)
	end
end
function s.applyrestrictions(c,rc)
	--Cannot be used as material for an Xyz or Link Summon
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e1:SetValue(aux.cannotmatfilter(SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e1,true)
	--Return it to the Extra Deck when it leaves the field
	local e2=Effect.CreateEffect(rc)
	e2:SetDescription(aux.Stringid(id,4))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e2:SetValue(LOCATION_DECKBOT)
	e2:SetReset(RESET_EVENT|RESETS_REDIRECT)
	c:RegisterEffect(e2,true)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattleTarget():IsSetCard(SET_ANGELECHY)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,tp,0)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.NegateAttack() then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.GetControl(c,1-tp)
	end
end