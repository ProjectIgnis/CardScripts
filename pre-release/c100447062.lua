--影雄の烬 エグリスタ
--Tohushaddoll Grysta
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Apply the effect of 1 non-Rock "Shaddoll" monster in your GY that activates when it is flipped face-up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.applytg)
	e1:SetOperation(s.applyop)
	c:RegisterEffect(e1)
	--Fusion Summon 1 "Shaddoll" Fusion Monster from your Extra Deck, by banishing its materials from your hand, field, and/or GY
	local fusion_params={
				fusfilter=function(c) return c:IsSetCard(SET_SHADDOLL) end,
				matfilter=Card.IsAbleToRemove,
				extrafil=s.fextra,
				extraop=Fusion.BanishMaterial,
				extratg=s.extratg}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e) return e:GetHandler():IsReason(REASON_EFFECT) and not Duel.IsPhase(PHASE_DAMAGE) end)
	e2:SetCost(s.fusioncost)
	e2:SetTarget(Fusion.SummonEffTG(fusion_params))
	e2:SetOperation(Fusion.SummonEffOP(fusion_params))
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(c) return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsSetCard(SET_SHADDOLL) end)
end
s.listed_series={SET_SHADDOLL}
function s.applyfilter(c,e,tp)
	if not (not c:IsRace(RACE_ROCK) and c:IsSetCard(SET_SHADDOLL) and c:IsMonster()) then return false end
	local effs={c:GetOwnEffects()}
	for _,eff in ipairs(effs) do
		if eff:GetType()&EFFECT_TYPE_FLIP>0 or eff:GetCode()==EVENT_FLIP then
			local tg=eff:GetTarget()
			if tg==nil or tg(eff,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,0) then
				return true
			end
		end
	end
	return false
end
function s.applytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.applyfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.applyfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	local available_effs={}
	local effs={tc:GetOwnEffects()}
	for _,eff in ipairs(effs) do
		if eff:GetType()&EFFECT_TYPE_FLIP>0 or eff:GetCode()==EVENT_FLIP then
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
	end
	e:SetLabelObject(eff)
	Duel.ClearOperationInfo(0)
end
function s.applyop(e,tp,eg,ep,ev,re,r,rp)
	local eff=e:GetLabelObject()
	if not (eff and eff:GetHandler():IsRelateToEffect(e)) then return end
	e:SetLabel(eff:GetLabel())
	e:SetLabelObject(eff:GetLabelObject())
	local op=eff:GetOperation()
	if op then
		op(e,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE)
	end
	e:SetLabel(0)
	e:SetLabelObject(nil)
end
function s.fusioncost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	--You cannot Special Summon from the Extra Deck the turn you activate this effect, except "Shaddoll" monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(SET_SHADDOLL) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE)
end