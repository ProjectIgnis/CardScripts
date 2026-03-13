--Ｓｉｎ Ｐａｒａｄｉｇｍ Ｓｈｉｆｔ
--Malefic Paradigm Shift
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--You can activate this card from your hand by paying half your LP
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetValue(function(e,c) e:SetLabel(1) end)
	c:RegisterEffect(e0)
	--Add to your hand, or place face-up in your Field Zone, 1 "Malefic World" from your Deck or GY, then Special Summon 1 "Malefic" monster from your Deck or Extra Deck in Defense Position, ignoring its Summoning conditions, then if your opponent controls a monster with 2500 or more ATK, all face-up monsters they currently control lose 2500 ATK until the end of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetLabelObject(e0)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
s.listed_names={27564031} --"Malefic World"
s.listed_series={SET_MALEFIC}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local label_obj=e:GetLabelObject()
	if chk==0 then label_obj:SetLabel(0) return true end
	if label_obj:GetLabel()==1 then
		label_obj:SetLabel(0)
		Duel.PayLPCost(tp,Duel.GetLP(tp)//2)
	end
end
function s.maleficworldfilter(c)
	return c:IsCode(27564031) and (c:IsAbleToHand() or not c:IsForbidden())
end
function s.spfilter(c,e,tp)
	if not (c:IsSetCard(SET_MALEFIC) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_DEFENSE)) then return false end
	if c:IsLocation(LOCATION_DECK) then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	elseif c:IsLocation(LOCATION_EXTRA) then
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.maleficworldfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,Duel.GetFieldGroup(tp,0,LOCATION_MZONE),1,tp,-2500)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.maleficworldfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil):GetFirst()
	local tohand_or_place_chk=aux.ToHandOrElse(sc,tp,
		function()
			return not sc:IsForbidden()
		end,
		function()
			local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
			if fc then
				Duel.SendtoGrave(fc,REASON_RULE)
				Duel.BreakEffect()
			end
			return Duel.MoveToField(sc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		end,
		aux.Stringid(id,3)
	)
	if not tohand_or_place_chk then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #sg==0 then return end
	Duel.BreakEffect()
	if Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP_DEFENSE)>0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttackAbove,2500),tp,0,LOCATION_MZONE,1,nil) then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		local c=e:GetHandler()
		Duel.BreakEffect()
		for tc in g:Iter() do
			--All face-up monsters they currently control lose 2500 ATK until the end of this turn
			tc:UpdateAttack(-2500,RESETS_STANDARD_PHASE_END,c)
		end
	end
end