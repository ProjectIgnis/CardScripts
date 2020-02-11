--CX 冀望皇バリアン (Anime)
--CXyz Barian Hope (Anime)
--fixed by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,7,3,nil,nil,5)
	c:EnableReviveLimit()
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(67926903,0))
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.xyzcon)
	e0:SetOperation(s.xyzop)
	e0:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e0)
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--copy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(id)
	c:RegisterEffect(e2)
	aux.GlobalCheck(s,function()
		--Copy
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetOperation(s.op)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_series={0x1048}
function s.cfilter(c)
	return c:IsHasEffect(511002571) and #{c:GetCardEffect(id0)}==0
end
function s.op(e)
	local g=Duel.GetMatchingGroup(s.cfilter,0,0xff,0xff,nil)
	for c in aux.Next(g) do
		local effs={c:GetCardEffect(511002571)}
		for _,eff in ipairs(effs) do
			local te=eff:GetLabelObject()
			local resetflag,resetcount=te:GetReset()
			local rm,max,code=te:GetCountLimit()
			local prop1,prop2=eff:GetProperty()
			local e1=Effect.CreateEffect(c)
			if te:GetDescription() then
				e1:SetDescription(te:GetDescription())
			end
			e1:SetLabelObject(te)
			e1:SetType(EFFECT_TYPE_XMATERIAL+te:GetType())
			if te:GetCode() then
				e1:SetCode(te:GetCode())
			end
			e1:SetProperty(prop1|EFFECT_FLAG_CARD_TARGET,prop2)
			e1:SetCondition(s.copycon)
			e1:SetCost(s.copycost)
			if max>0 then
				e1:SetCountLimit(max,code)
			end
			if te:GetTarget() then
				e1:SetTarget(te:GetTarget())
			end
			if te:GetOperation() then
				e1:SetOperation(te:GetOperation())
			end
			if resetflag and resetcount then
				e1:SetReset(resetflag,resetcount)
			elseif resetflag then
				e1:SetReset(resetflag)
			end
			c:RegisterEffect(e1,true)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(id0)
			e2:SetProperty(prop1,prop2)
			if resetflag and resetcount then
				e2:SetReset(resetflag,resetcount)
			elseif resetflag then
				e2:SetReset(resetflag)
			end
			c:RegisterEffect(e2,true)
		end
	end
end
function s.copycon(e,tp,eg,ep,ev,re,r,rp)
	local con=e:GetLabelObject():GetCondition()
	return e:GetHandler():IsHasEffect(id) and Duel.GetTurnPlayer()==tp
		and e:GetOwner():GetFlagEffect(id)==0
		and (not con or con(e,tp,eg,ep,ev,re,r,rp))
end
function s.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=e:GetOwner()
	local a=c:CheckRemoveOverlayCard(tp,1,REASON_COST)
	local b=Duel.CheckLPCost(tp,400)
	local ov=c:GetOverlayGroup()
	if chk==0 then return a or b end
	Duel.Hint(HINT_CARD,0,tc:GetOriginalCode())
	Duel.SetTargetCard(tc)
	local op=0
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(76922029,0))
	if a and b then
		op=Duel.SelectOption(tp,aux.Stringid(81330115,0),aux.Stringid(21454943,1))
	elseif a and not b then
		Duel.SelectOption(tp,aux.Stringid(81330115,0))
		op=0
	else
		Duel.SelectOption(tp,aux.Stringid(21454943,1))
		op=1
	end
	if op==0 then
		Duel.SendtoGrave(tc,REASON_COST) 
	else
		Duel.PayLPCost(tp,400)
	end
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.ovfilter(c)
	local class=c:GetMetatable(true)
	if class==nil then return false end
	local no=class.xyz_number
	return c:IsFaceup() and no and no>=101 and no<=107 and c:IsSetCard(0x1048)
end
function s.xyzcon(e,c,og)
	if c==nil then return true end
	local tp=c:GetControler()
	local mg=Duel.GetMatchingGroup(s.ovfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	return #mg>0 and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c,og)
	og=Group.CreateGroup()
	local mg=Duel.GetMatchingGroup(s.ovfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	og:Merge(mg)
	local tc=mg:GetFirst()
	while tc do
		local ov=tc:GetOverlayGroup()
		if #ov>0 then
			Duel.Overlay(c,ov)
			og:Merge(ov)
		end
		tc=mg:GetNext()
	end
	c:SetMaterial(og)
	Duel.Overlay(c,og)
end
function s.atkval(e,c)
	return c:GetOverlayCount()*1000
end