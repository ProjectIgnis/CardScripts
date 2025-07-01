--ＲＲ－ラピッド・エクシーズ
--Raidraptor - Rapid Xyz
local s,id=GetID()
function s.initial_effect(c)
	--Immediately after this effect resolves, Xyz Summon 1 "Raidraptor" Xyz Monster using monsters you control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
	e1:SetCondition(function(_,tp) return Duel.IsBattlePhase() and Duel.IsExistingMatchingCard(Card.IsSpecialSummoned,tp,0,LOCATION_MZONE,1,nil) end)
	e1:SetTarget(s.xyztg)
	e1:SetOperation(s.xyzop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_RAIDRAPTOR}
function s.xyzfilter(c)
	return c:IsXyzSummonable() and c:IsSetCard(SET_RAIDRAPTOR)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	if tc then
		--The Summoned monster can activate its effects that activate by detaching an Xyz Material(s)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_QUICK_O)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCondition(function() return Duel.IsBattlePhase() end)
		e1:SetTarget(s.acttg)
		e1:SetOperation(s.actop)
		e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TOFIELD)|RESET_PHASE|PHASE_END)
		tc:RegisterEffect(e1,true)
		Duel.XyzSummon(tp,tc)
	end
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local effs={}
	for _,eff in ipairs({c:GetOwnEffects(id)}) do
		if eff:HasDetachCost() then table.insert(effs,eff) end
	end
	if chkc then
		for _,eff in ipairs(effs) do
			if eff:GetFieldID()==e:GetLabel() then return eff:GetTarget()(e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
		end
		return false
	end
	local options={}
	local has_option=false
	for _,eff in ipairs(effs) do
		e:SetCategory(eff:GetCategory())
		e:SetProperty(eff:GetProperty())
		local con=eff:GetCondition()
		local cost=eff:GetCost()
		local tg=eff:GetTarget()
		local eff_chk=eff:GetCountLimit()>0
			and (not con or con(e,tp,eg,ep,ev,re,r,rp))
			and (not cost or cost(e,tp,eg,ep,ev,re,r,rp,0))
			and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0))
		if eff_chk then has_option=true end
		table.insert(options,{eff_chk,eff:GetDescription()})
	end
	e:SetCategory(0)
	e:SetProperty(0)
	if chk==0 then return has_option end
	local op=#options==1 and 1 or Duel.SelectEffect(tp,table.unpack(options))
	if not op then return end
	local te=effs[op]
	if not te then return end
	e:SetLabel(te:GetFieldID())
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	local cost=te:GetCost()
	if cost then cost(e,tp,eg,ep,ev,re,r,rp,1) end
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	te:UseCountLimit(tp)
	e:SetOperation(te:GetOperation())
end
