--ヴォルカライジング・サラマンデウス
--Volcalizing Salamandeus
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,160010020,1,s.ffilter,1)
	--Verify materials
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)
	--Decrease ATK
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetLabelObject(e0)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.named_material={160010020}
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local atk=0
	for tc in g:Iter() do
		if tc:WasMaximumMode() then
			e:SetLabel(1)
		end
	end
end
function s.ffilter(c,fc,sumtype,tp)
	return c:IsType(TYPE_MAXIMUM,scard,sumtype,tp) and c:IsRace(RACE_PYRO|RACE_THUNDER|RACE_AQUA,scard,sumtype,tp)
end
function s.cfilter(c)
	return c:IsMonster() and c:IsType(TYPE_MAXIMUM) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,3,nil) end
end
function s.filter(c)
	return c:IsFaceup() and not c:IsMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil)	end
end
function s.tdfilter(c,tp)
	return c:IsLocation(LOCATION_DECK) and c:IsOwner(tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	Duel.HintSelection(tg,true)
	local opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	if opt==0 then
		Duel.SendtoDeck(tg,nil,SEQ_DECKTOP,REASON_EFFECT)
		local td=Duel.GetOperatedGroup():Filter(s.tdfilter,nil,tp)
		if #td>1 then
			Duel.SortDecktop(tp,tp,#td)
		end
	elseif opt==1 then
		local ct=Duel.SendtoDeck(tg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		local td=Duel.GetOperatedGroup():Filter(s.tdfilter,nil,tp)
		if #td>1 then
			Duel.SortDeckbottom(tp,tp,#td)
		end
	end
	--Effect
	local sg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	for tc in sg:Iter() do
		--Decrease ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-3000)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		if c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabelObject():GetLabel()==1 then
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,3))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_EXTRA_ATTACK)
			e1:SetValue(2)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end