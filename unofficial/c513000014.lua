--TG ハルバード・キャノン (Anime)
--T.G. Halberd Cannon (Anime)
--Fixed by Larry126 and The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_SYNCHRO),1,1,Synchro.NonTunerEx(Card.IsType,TYPE_SYNCHRO),2,99)
	c:EnableReviveLimit()
	--Negate Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SUMMON)
	e1:SetCondition(function() return Duel.GetCurrentChain()==0 end)
	e1:SetCost(s.discost)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e3)
	--Special Summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	--Negate Effect
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_DISABLE)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_CHAINING)
	e5:SetCondition(s.negcon)
	e5:SetTarget(s.negtg)
	e5:SetOperation(s.negop)
	c:RegisterEffect(e5)
end
s.listed_names={51447164}
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSynchroSummoned() and c:GetMaterialCount()>0 and c:GetFlagEffect(id)<c:GetMaterialCount() end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	Duel.NegateSummon(eg)
	Duel.Destroy(eg,REASON_EFFECT)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP)
end
function s.spfilter(c,e,tp)
	return c:IsCode(51447164) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,true)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,true,POS_FACEUP)
	end
end
function s.filter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and not c:IsControler(tp)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp,chk)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainDisablable(ev)
		or Duel.GetCurrentPhase()==PHASE_DAMAGE and Duel.IsDamageCalculated() then return false end
	for i=0,5 do --Loop through CATEGORY_DESTROY/RELEASE/REMOVE/TOHAND/TODECK/TOGRAVE
		local cate=2^i
		local ex,tg,tc=Duel.GetOperationInfo(ev,cate)
		if ex and tg~=nil and tc+tg:FilterCount(s.filter,nil,tp)-#tg>0 then
			local g=tg:Filter(s.filter,nil,tp)
			g:KeepAlive()
			e:SetLabelObject(g)
			return true
		end
	end
	return false
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	Duel.SetTargetCard(e:GetLabelObject())
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) then
		local c=e:GetHandler()
		local tg=Duel.GetTargetCards(e)
		for tc in aux.Next(tg) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(-800)
			tc:RegisterEffect(e1)
		end
	end
end