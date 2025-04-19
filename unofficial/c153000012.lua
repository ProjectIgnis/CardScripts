--レアメタル・ナイト (Deck Master)
--Super Roboyarou (Deck Master)
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	if not DeckMaster then
		return
	end
	--Deck Master Effect
	local dme1=Effect.CreateEffect(c)
	dme1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	dme1:SetCode(EVENT_BATTLE_START)
	dme1:SetCondition(s.dmcon)
	dme1:SetOperation(s.dmop)
	DeckMaster.RegisterAbilities(c,dme1)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,92421852,38916461)
	--atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.atkcon)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={75923050}
function s.atkcon(e)
	local ph=Duel.GetCurrentPhase()
	if not (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) then return false end
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return a==e:GetHandler() and d~=nil
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetTurnID()~=Duel.GetTurnCount()
end
function s.spfilter(c,e,tp,mc)
	return c:IsCode(75923050) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtra()
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.SendtoDeck(c,nil,2,REASON_EFFECT)~=0 then
		local tc=Duel.GetFirstMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
		if tc then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.filter(c)
	return c:IsSpellTrap() and c:IsSSetable()
end
function s.dmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttackTarget() and (Duel.GetAttackTarget():IsControler(tp) or Duel.GetAttacker():IsControler(tp))
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil) and Duel.IsDeckMaster(tp,id)
end
function s.dmop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_CARD,1-tp,id)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
	Duel.SSet(tp,tc,tp,false)
end