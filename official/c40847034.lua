--キラーチューン・プレイリスト
--Kewl Tune Playlist
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Apply these effects, in sequence, also you cannot Special Summon for the rest of this turn after this card resolves, except Tuners
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(2,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
s.listed_series={SET_KEWL_TUNE}
function s.applyfilter(c,e,tp)
	if not (c:IsSetCard(SET_KEWL_TUNE) and c:IsMonster() and c:IsFaceup()) then return false end
	if c:IsAbleToHand() then return true end
	local effs={c:GetOwnEffects()}
	for _,eff in ipairs(effs) do
		if eff:GetCode()==EVENT_BE_MATERIAL then
			local tg=eff:GetTarget()
			if tg==nil or tg(eff,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,0) then
				return true
			end
		end
	end
	return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.applyfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.applyfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	local available_effs={}
	local effs={tc:GetOwnEffects()}
	for _,eff in ipairs(effs) do
		if eff:GetCode()==EVENT_BE_MATERIAL then
			local tg=eff:GetTarget()
			if tg==nil or tg(eff,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,0) then
				table.insert(available_effs,eff)
			end
		end
	end
	local eff=nil
	if #available_effs>1 then
		local available_effs_desc={}
		for _,eff in ipairs(available_effs) do
			table.insert(available_effs_desc,eff:GetDescription())
		end
		local op=Duel.SelectOption(tp,table.unpack(available_effs_desc))
		eff=available_effs[op+1]
	else
		eff=available_effs[1]
	end
	if eff then
		Duel.Hint(HINT_OPSELECTED,1-tp,eff:GetDescription())
		Duel.ClearTargetCard()
		tc:CreateEffectRelation(e)
		e:SetLabel(eff:GetLabel())
		e:SetLabelObject(eff:GetLabelObject())
		local tg=eff:GetTarget()
		if tg then
			tg(e,tp,eg,ep,ev,re,r,rp,1)
			eff:SetLabel(e:GetLabel())
			eff:SetLabelObject(e:GetLabelObject())
			Duel.ClearOperationInfo(0)
		end
		e:SetLabelObject(eff)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local _,tc=Duel.GetOperationInfo(0,CATEGORY_TOHAND)
	tc=tc:GetFirst()
	if tc and tc:IsRelateToEffect(e) then
		local te=e:GetLabelObject()
		if te then
			local break_chk=false
			--Apply its effect that activates if sent to the GY as Synchro Material
			local op=te:GetOperation()
			if tc:IsFaceup() and op then
				e:SetLabel(te:GetLabel())
				e:SetLabelObject(te:GetLabelObject())
				op(e,tp,eg,ep,ev,re,r,rp)
				break_chk=true
			end
			e:SetLabel(0)
			e:SetLabelObject(nil)
		end
		--Return it to the hand
		if break_chk then Duel.BreakEffect() end
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	--You cannot Special Summon for the rest of this turn after this card resolves, except Tuners
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
	if c:IsMonster() then
		return not c:IsType(TYPE_TUNER)
	elseif c:IsMonsterCard() then
		return not c:IsOriginalType(TYPE_TUNER)
	end
end