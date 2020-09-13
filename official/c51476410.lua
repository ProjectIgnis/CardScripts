--クロック・リザード
-- Clock Lizard
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_CYBERSE),2)
	--fusion summon
	local e1=Fusion.CreateSummonEff({handler=c,location=LOCATION_GRAVE,fusfilter=s.lizardcheck,matfilter=aux.FALSE,
									extrafil=s.extrafil,preselect=s.preop,desc=aux.Stringid(id,0),
									extraop=Fusion.BanishMaterial,nosummoncheck=true,chkf=PLAYER_NONE})
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.spcost)
	e1:SetTarget((function(tg)
		return function(e,tp,eg,ep,ev,re,r,rp,chk)
			local gate=Duel.GetMetatable(CARD_SUMMON_GATE)
			local ect=gate and Duel.IsPlayerAffectedByEffect(tp,CARD_SUMMON_GATE) and gate[tp]
			if chk==0 then
				return Duel.IsPlayerCanRemove(tp) and ect~=0 and tg(e,tp,eg,ep,ev,re,r,rp,chk)
			end
			Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_GRAVE)
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
		end
	end)(e1:GetTarget()))
	c:RegisterEffect(e1)
	--remove
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.lizardcheck(c,tp)
	return c:IsAbleToExtra() and not c:IsHasEffect(CARD_CLOCK_LIZARD)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetOriginalCode(),{c:GetOriginalSetCard()},c:GetOriginalType(),c:GetBaseAttack(),c:GetBaseDefense(),c:GetOriginalLevel(),c:GetOriginalRace(),c:GetOriginalAttribute())
end
function s.checkextra(c)
	return function(tp,sg,fc)
		return (fc:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,sg,fc) or Duel.GetLocationCountFromEx(tp,tp,sg+c,TYPE_FUSION))>0
	end
end
function s.extrafil(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,Duel.IsPlayerAffectedByEffect(tp,69832741) and LOCATION_MZONE or LOCATION_GRAVE,0,nil),s.checkextra(e:GetHandler())
end
function s.preop(e,tc)
	return Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)~=0
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsPreviousLocation(LOCATION_GRAVE)
end
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE,0,1,nil,RACE_CYBERSE)
		and Duel.IsExistingMatchingCard(s.atkfilter,tp,0,LOCATION_MZONE,1,nil) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	local atk=Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_CYBERSE)*400
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end