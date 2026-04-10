--メルフィー・ラッシィ
--Melffy Pinny
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--If a face-up Beast monster you control was returned to the hand this turn, except "Melffy Pinny" (Quick Effect): You can Special Summon this card from your hand, then immediately after this effect resolves, Synchro Summon 1 Synchro Monster using only this card you control and "Melffy" monsters in your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCondition(function(_,tp) return Duel.HasFlagEffect(tp,id) end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--During your End Phase, if this card is in your GY: You can target 1 Beast Xyz Monster you control; attach this card to it as material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(_,tp) return Duel.IsTurnPlayer(tp) end)
	e2:SetTarget(s.atttg)
	e2:SetOperation(s.attop)
	c:RegisterEffect(e2)
	--Track cards that return to hand
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_HAND)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_names={id}
s.listed_series={SET_MELFFY}
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for tc in eg:Iter() do
		if tc:IsPreviousLocation(LOCATION_MZONE) and tc:IsPreviousPosition(POS_FACEUP)
			and tc:IsPreviousRaceOnField(RACE_BEAST) and not tc:IsPreviousCodeOnField(id) then
			return Duel.RegisterFlagEffect(tc:GetPreviousControler(),id,RESET_PHASE|PHASE_END,0,1)
		end
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local mg=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_HAND,0,nil,SET_MELFFY)
	if #mg==0 then return end
	local sg=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c,mg+c)
	if #sg==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=sg:Select(tp,1,1,nil):GetFirst()
	if sc then
		Duel.BreakEffect()
		Duel.SynchroSummon(tp,sc,c,mg+c)
	end
end
function s.xyzfilter(c,ac,tp)
	return c:IsRace(RACE_BEAST) and c:IsXyzMonster() and c:IsFaceup() and ac:IsCanBeXyzMaterial(c,tp,REASON_EFFECT)
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.afilter(chkc,c,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,c,tp)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) 
		and c:IsCanBeXyzMaterial(tc,tp,REASON_EFFECT)
		and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(tc,c)
	end
end
