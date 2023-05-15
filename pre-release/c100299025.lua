--異界共鳴－シンクロ・フュージョン
--Harmonic Synchro Fusion
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
function s.counterfilter(c)
	return not (c:IsSummonLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION|TYPE_SYNCHRO))
end
function s.cfilter1(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_TUNER) and c:IsAbleToGraveAsCost() and not c:IsOriginalType(TYPE_TRAP)
		and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,c,e,tp,c)
end
function s.cfilter2(c,e,tp,tun)
	if not (c:IsFaceup() and not c:IsType(TYPE_TUNER) and c:IsAbleToGraveAsCost() and not c:IsOriginalType(TYPE_TRAP)) then return false end
	local g=Group.FromCards(tun,c)
	for tc in g:Iter() do
		tc:AssumeProperty(ASSUME_CODE,tc:GetOriginalCode())
		tc:AssumeProperty(ASSUME_TYPE,tc:GetOriginalType())
		tc:AssumeProperty(ASSUME_LEVEL,tc:GetOriginalLevel())
		tc:AssumeProperty(ASSUME_ATTRIBUTE,tc:GetOriginalAttribute())
		tc:AssumeProperty(ASSUME_RACE,tc:GetOriginalRace())
		tc:AssumeProperty(ASSUME_ATTACK,tc:GetTextAttack())
		tc:AssumeProperty(ASSUME_DEFENSE,tc:GetTextDefense())
	end
	local chk=Duel.GetLocationCountFromEx(tp,tp,g,TYPE_FUSION)>=2 
		and Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g)
		and Duel.IsExistingMatchingCard(s.syncfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g)
	Duel.AssumeReset()
	return chk
end
function s.fusfilter(c,e,tp,mg)
	if not (c:IsFacedown() and c:IsType(TYPE_FUSION) and (not c.material_location or (c.material_location&LOCATION_GRAVE)>0)) then return false end
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:CheckFusionMaterial(mg)
end
function s.syncfilter(c,e,tp,mg)
	if not (c:IsFacedown() and c:IsType(TYPE_SYNCHRO)) then return false end
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSynchroSummonable(nil,mg)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
		and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tun=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local nt=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_MZONE,0,1,1,tun,e,tp,tun):GetFirst()
	local g=Group.FromCards(tun,nt)
	Duel.SendtoGrave(g,REASON_COST)
	Duel.SetTargetCard(g)
	local c=e:GetHandler()
	--Cannot Special Summon from the Extra Deck, except Fusion and Synchro Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION|TYPE_SYNCHRO) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Clock Lizard check
	aux.addTempLizardCheck(c,tp,function(_,c) return not c:IsOriginalType(TYPE_FUSION|TYPE_SYNCHRO) end)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetTargetCards(e)
	if #mg~=2 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCountFromEx(tp,tp,mg,TYPE_FUSION)<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local fc=Duel.SelectMatchingCard(tp,s.fusfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg):GetFirst()
	if not fc then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.syncfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg):GetFirst()
	if not sc then return end
	local g=Group.FromCards(fc,sc)
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end