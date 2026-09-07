--断絶拳
--Extinction Fist
local s,id=GetID()
function s.initial_effect(c)
	--When an opponent's Fusion or Ritual monster declares a direct attack: Destroy that monster, and Special Summon the Material(s) that were used to Summon that monster from your opponent's Graveyard to their side of the field, then, end the Battle Phase.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(function(e,tp) return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.mgfilter(c,e,tp,fusrit)
	return c:IsControler(1-tp) and c:IsLocation(LOCATION_GRAVE)
		and ((c:GetReason()&(REASON_MATERIAL|REASON_RITUAL)==(REASON_MATERIAL|REASON_RITUAL)) or (c:GetReason()&(REASON_MATERIAL|REASON_FUSION)==(REASON_MATERIAL|REASON_FUSION))) and c:GetReasonCard()==fusrit
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=Duel.GetAttacker()
	local mg=tg:GetMaterial():Filter(aux.NecroValleyFilter(s.mgfilter),nil,e,tp,tg)
	local ft=Duel.GetMZoneCount(1-tp,tg)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if chk==0 then return (tg:IsRitualMonster() or tg:IsFusionMonster()) and #mg>0 and #mg<=ft end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,mg,#mg,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetAttacker()
	if not (tg:IsFaceup() and tg:IsOnField() and tg:IsDestructable()) then return end
	local mg=tg:GetMaterial():Filter(aux.NecroValleyFilter(s.mgfilter),nil,e,tp,tg)
	local ft=Duel.GetMZoneCount(1-tp,tg)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if tg and Duel.Destroy(tg,REASON_EFFECT)>0 and #mg>0 and #mg<=ft then
		if Duel.SpecialSummon(mg,0,tp,1-tp,false,false,POS_FACEUP)>0 then
			Duel.BreakEffect()
			Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE|PHASE_BATTLE,1)
		end
	end
end
