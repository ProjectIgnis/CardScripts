--Elemental HERO Favorite Neos
--AlphaKretin
function c210310060.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcMix(c,true,true,89943723,35809262)
	aux.AddContactFusion(c,c210310060.contactfil,c210310060.contactop,c210310060.splimit)
	--damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35809262,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c210310060.damcon)
	e1:SetTarget(c210310060.damtg)
	e1:SetOperation(c210310060.damop)
	c:RegisterEffect(e1)
	--may not return
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(42015635)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,210310060)
	e3:SetTarget(c210310060.sptg)
	e3:SetOperation(c210310060.spop)
	c:RegisterEffect(e3)
end
c210310060.material_setcode={0x8,0x3008,0x9}
function c210310060.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_ONFIELD,0,nil)
end
function c210310060.contactop(g,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoDeck(g,nil,2,REASON_COST+REASON_MATERIAL)
end
function c210310060.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
function c210310060.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsType(TYPE_MONSTER)
end
function c210310060.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	Duel.SetTargetCard(bc)
	local dam=bc:GetBaseAttack()
	if dam<0 then dam=0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function c210310060.damop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local dam=tc:GetAttack()
		if dam<0 then dam=0 end
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end
function c210310060.spcfilter(c,e,tp)
	return (c:IsSetCard(0x3008) or c:IsSetCard(0x1f)) and c:IsReleasable() and c:IsFaceup() and Duel.IsExistingMatchingCard(c210310060.spfilter,tp,LOCATION_EXTRA,0,1,nil,c,e,tp)
end
function c210310060.spfilter(c,mc,e,tp)
	return c:IsType(TYPE_FUSION) and c.material and mc:IsCode(table.unpack(c.material)) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
function c210310060.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c210310060.spcfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(c210310060.spcfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectTarget(tp,c210310060.spcfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function c210310060.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if (Duel.Release(tc,REASON_EFFECT)>0) then
		local sg=Duel.SelectMatchingCard(tp,c210310060.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,tc,e,tp)
		if sg:GetCount()>0 then
			local sc=sg:GetFirst()
			if sc and Duel.SpecialSummonStep(sc,0,tp,tp,true,false,POS_FACEUP) then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e1:SetRange(LOCATION_MZONE)
				e1:SetCountLimit(1)
				e1:SetOperation(c210310060.tdop)
				e1:SetReset(RESET_EVENT+0x1fe0000)
				sc:RegisterEffect(e1,true)
			end
			Duel.SpecialSummonComplete()
		end
	end
end
function c210310060.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_EFFECT)
end