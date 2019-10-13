--Time Magic Hammer
--reworked by senpaizuri
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcCodeFun(c,71625222,46232525,1,true,true)
	--spsummon condition
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	--Activate
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
	--Equip limit
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
s.listed_names={71625222}
function s.hermos_filter(c)
	return c:IsCode(71625222)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsLocation(LOCATION_SZONE) and tc:IsLocation(LOCATION_MZONE) then
		if Duel.Equip(tp,c,tc) and not c:IsDisabled() then
			local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
			local ct=#g
			if ct==0 then return end
			local t={}
			for i=1,#g do
				table.insert(t,Duel.TossDice(tp,1))
			end
			table.sort(t)
			for i=1,ct do
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
				local tg=g:Select(tp,1,1,nil)
				Duel.HintSelection(tg)
				local m,n=Duel.AnnounceNumber(tp,table.unpack(t))
				table.remove(t,n+1)
				local tc=tg:GetFirst()
				tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_REDIRECT-RESET_TEMP_REMOVE,0,1,m)
				g:RemoveCard(tc)
			end
			--Future Swing
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
			e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
			e1:SetCountLimit(1)
			e1:SetRange(LOCATION_SZONE)
			e1:SetLabel(10)
			e1:SetCondition(s.con)
			e1:SetOperation(s.act)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
		end
	end
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.filter(c,rc,ct)
	return rc:GetCardTarget():IsContains(c) and c:GetFlagEffect(id)>0
		and c:GetFlagEffectLabel(id)==ct
end
function s.act(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==10 then
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,nil)
		Duel.Remove(g,nil,REASON_EFFECT+REASON_TEMPORARY)
		local maxct=0
		for tc in aux.Next(g) do
			if tc:GetFlagEffect(id)>0 then
				c:SetCardTarget(tc)
				local ct=tc:GetFlagEffectLabel()
				maxct=math.max(ct,maxct)
			end
		end
		if maxct==7 then
			c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
			e:SetLabel(7)
		else
			e:SetLabel(6)
		end
	elseif e:GetLabel()>0 then
		if c:GetFlagEffect(id)>0 then 
			c:SetTurnCounter(8-e:GetLabel())
			g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil,c,8-e:GetLabel())
		else
			c:SetTurnCounter(7-e:GetLabel())
			g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil,c,7-e:GetLabel())
		end
		if #g>0 then
			local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
			if #g>=ft then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
				local sg=g:Select(1-tp,ft,ft,nil)
				for tc in aux.Next(sg) do
					Duel.ReturnToField(tc)
					g:RemoveCard(tc)
				end
				Duel.SendtoGrave(g,REASON_RULE+REASON_RETURN)
			else
				for tc in aux.Next(g) do
					Duel.ReturnToField(tc)
				end
			end
		end
		e:SetLabel(e:GetLabel()-1)
		if e:GetLabel()==0 then e:Reset() end
	end
end
