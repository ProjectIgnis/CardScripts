--Ｗ：Ｐファンシーボール
--W:P Fancy Ball
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2+ Effect Monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2)
	--When your opponent activates a monster effect on the field or GY (Quick Effect): You can banish this card that was Special Summoned this turn until the End Phase; negate that effect, and if you do, banish it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.discon)
	e1:SetCost(s.discost)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--During your opponent's Main Phase, you can (Quick Effect): Immediately after this effect resolves, Link Summon 1 Link Monster, and if this card you control would be used as material for that Link Summon, you can also use 1 Link-2 or lower monster your opponent controls
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp) return Duel.IsMainPhase(1-tp) end)
	e2:SetTarget(s.linktg)
	e2:SetOperation(s.linkop)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e2)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp,chk)
	if not e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN) then return false end
	local trig_loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return ep==1-tp and re:IsMonsterEffect() and trig_loc&(LOCATION_MZONE|LOCATION_GRAVE)>0 and Duel.IsChainDisablable(ev)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	--Banish this card until the End Phase
	aux.RemoveUntil(c,nil,REASON_COST,PHASE_END,id,e,tp,aux.DefaultFieldReturnOp)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	local relation=rc:IsRelateToEffect(re)
	if chk==0 then return rc:IsAbleToRemove(tp)
		or (not relation and Duel.IsPlayerCanRemove(tp)) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,tp,0)
	if relation then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,tp,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,rc:GetPreviousLocation())
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
function s.linktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		--If this card you control would be used as material for that Link Summon, you can also use 1 Link-2 or lower monster your opponent controls
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_MATERIAL)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(1,0)
		e1:SetOperation(s.extracon)
		e1:SetValue(s.extraval)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
		local res=Duel.IsExistingMatchingCard(Card.IsLinkSummonable,tp,LOCATION_EXTRA,0,1,nil)
		e1:Reset()
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetChainLimit(function(re,rp,tp) return not (re:IsMonsterEffect() and re:GetHandler():IsLinkMonster()) end)
end
function s.linkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=nil
	if c:IsRelateToEffect(e) then
		--If this card you control would be used as material for that Link Summon, you can also use 1 Link-2 or lower monster your opponent controls
		e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_MATERIAL)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(1,0)
		e1:SetOperation(s.extracon)
		e1:SetValue(s.extraval)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,Card.IsLinkSummonable,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	if sc then
		Duel.LinkSummon(tp,sc)
		if e1 then
			local eff_code=Duel.GetCurrentChain()==1 and EVENT_SPSUMMON or EVENT_SPSUMMON_SUCCESS
			--Reset e1
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(eff_code)
			e2:SetOperation(function(e) e1:Reset() e:Reset() end)
			Duel.RegisterEffect(e2,tp)
		end
	elseif e1 then
		e1:Reset()
	end
end
function s.extracon(c,e,tp,sg,mg,lc,og,chk)
	if not sg:IsContains(e:GetHandler()) then return false end
	local g=Duel.GetMatchingGroup(Card.IsLinkBelow,tp,0,LOCATION_MZONE,nil,2)
	if #g==0 then return true end
	local max_count=1
	local must_include=Group.CreateGroup()
	local effs={Duel.GetPlayerEffect(tp,EFFECT_EXTRA_MATERIAL)}
	for _,eff in ipairs(effs) do
		if not eff:GetOwner():IsCode(id) then
			if #(eff:GetValue()(0,SUMMON_TYPE_LINK,eff,tp,lc))>0 then
				local handler=eff:GetHandler()
				must_include:Merge(handler)
				if #(sg&must_include)>0 or lc==handler then
					max_count=max_count+1
				end
			end
		end
	end
	return #(sg&g)>0 and #(sg&g)<=max_count
end
function s.extraval(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK then
			return Group.CreateGroup()
		else
			return Duel.GetMatchingGroup(Card.IsLinkBelow,tp,0,LOCATION_MZONE,nil,2)
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_LINK==SUMMON_TYPE_LINK and #sg>0 then
			Duel.Hint(HINT_CARD,tp,id)
		end
	end
end