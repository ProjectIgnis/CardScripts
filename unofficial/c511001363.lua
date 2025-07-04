--ＣＸ 冀望皇バリアン (Anime)
--CXyz Barian Hope (Anime)
--Rescripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3+ Level 7 monsters
	Xyz.AddProcedure(c,nil,7,3,nil,nil,Xyz.InfiniteMats)
	--For this card's Xyz Summon, you can treat all "Number C10X" Xyz Monsters on the field as Level 7
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_FIELD)
	e0a:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e0a:SetCode(EFFECT_XYZ_MATERIAL)
	e0a:SetRange(0xff&~LOCATION_MZONE)
	e0a:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e0a:SetTarget(s.xyztg)
	e0a:SetValue(function(e,ec,rc,tp) return rc==e:GetHandler() end)
	c:RegisterEffect(e0a)
	local e0b=e0a:Clone()
	e0b:SetCode(EFFECT_XYZ_LEVEL)
	e0b:SetValue(function(e,mc,rc)
		if rc==e:GetHandler() then return 7,mc:GetLevel() end
		return mc:GetLevel()
	end)
	c:RegisterEffect(e0b)
	--This card's ATK is equal to the number of Xyz Materials attached to it x 1000
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,ec) return ec:GetOverlayCount()*1000 end)
	c:RegisterEffect(e1)
	--Activate the effect of 1 Xyz Monster attached to this card that activates by detaching its own Xyz Material(s)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.copycost)
	e2:SetTarget(s.copytg)
	e2:SetOperation(s.copyop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_NUMBER_C}
function s.xyztg(e,c)
	local no=c.xyz_number
	return c:IsFaceup() and no and no>=101 and no<=107 and c:IsSetCard(SET_NUMBER_C)
end
function s.copyfilter(c,e,tp)
	if not c:IsType(TYPE_XYZ) or c:HasFlagEffect(id) then return false end
	local effs={c:GetOwnEffects()}
	for _,eff in ipairs(effs) do
		if eff:HasDetachCost() then
			local con=eff:GetCondition()
			local tg=eff:GetTarget()
			if (con==nil or con(eff,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,0))
				and (tg==nil or tg(eff,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,0)) then
				return true
			end
		end
	end
	return false
end
function s.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=c:CheckRemoveOverlayCard(tp,1,REASON_COST)
	local b2=Duel.CheckLPCost(tp,400)
	if chk==0 then return (b1 or b2) and c:GetOverlayGroup():IsExists(s.copyfilter,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local sc=c:GetOverlayGroup():FilterSelect(tp,s.copyfilter,1,1,nil,e,tp):GetFirst()
	Duel.Hint(HINT_CARD,0,sc:GetOriginalCodeRule())
	sc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,2)},{b2,aux.Stringid(id,3)})
	if op==1 then
		Duel.SendtoGrave(sc,REASON_COST)
	else
		Duel.PayLPCost(tp,400)
	end
	local available_effs={}
	local effs={sc:GetOwnEffects()}
	for _,eff in ipairs(effs) do
		if eff:HasDetachCost() then
			local con=eff:GetCondition()
			local tg=eff:GetTarget()
			if (con==nil or con(e,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,0))
				and (tg==nil or tg(e,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,0)) then
				table.insert(available_effs,eff)
			end
		end
	end
	e:SetLabelObject(available_effs)
end
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
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
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
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
