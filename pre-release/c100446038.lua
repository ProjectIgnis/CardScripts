--キラーチューン・ラウドネスウォー
--Killer Tune Loudness War
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner + 1+ Tuners
	Synchro.AddProcedure(c,nil,1,1,aux.FilterBoolFunctionEx(Card.IsType,TYPE_TUNER),1,99)
	--Other Tuners you control cannot be destroyed by card effects, also your opponent cannot target them with card effects
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetTargetRange(LOCATION_MZONE,0)
	e1a:SetTarget(function(e,c) return c:IsType(TYPE_TUNER) and c~=e:GetHandler() end)
	e1a:SetValue(1)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1b:SetValue(aux.tgoval)
	c:RegisterEffect(e1b)
	--Apply the effect of 1 "Killer Tune" monster in your GY that activates if sent to the GY as Synchro Material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==1-tp end)
	e2:SetCost(s.applycost)
	e2:SetTarget(s.applytg)
	e2:SetOperation(s.applyop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_KILLER_TUNE}
function s.rmfilter(c,e,tp)
	if not (c:IsSetCard(SET_KILLER_TUNE) and c:IsMonster() and c:IsAbleToRemoveAsCost()) then return false end
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
function s.applycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rc=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	Duel.Remove(rc,POS_FACEUP,REASON_COST)
	local available_effs={}
	local effs={rc:GetOwnEffects()}
	for _,eff in ipairs(effs) do
		if eff:GetCode()==EVENT_BE_MATERIAL then
			local tg=eff:GetTarget()
			if tg==nil or tg(eff,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,0) then
				table.insert(available_effs,eff)
			end
		end
	end
	e:SetLabelObject(available_effs)
end
function s.applytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local eff=e:GetLabelObject()
		return eff and eff:GetTarget() and eff:GetTarget()(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	if chk==0 then return true end
	local eff=nil
	local available_effs=e:GetLabelObject()
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
	e:SetLabel(eff:GetLabel())
	e:SetLabelObject(eff:GetLabelObject())
	e:SetProperty(eff:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and EFFECT_FLAG_CARD_TARGET or 0)
	local tg=eff:GetTarget()
	if tg then
		tg(e,tp,eg,ep,ev,re,r,rp,1)
	end
	eff:SetLabel(e:GetLabel())
	eff:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(eff)
	Duel.ClearOperationInfo(0)
end
function s.applyop(e,tp,eg,ep,ev,re,r,rp)
	local eff=e:GetLabelObject()
	if not eff then return end
	e:SetLabel(eff:GetLabel())
	e:SetLabelObject(eff:GetLabelObject())
	local op=eff:GetOperation()
	if op then
		op(e,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE)
	end
	e:SetLabel(0)
	e:SetLabelObject(nil)
end