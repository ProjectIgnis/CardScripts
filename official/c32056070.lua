--ユウ-Ai-
--You & A.I.
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--apply effecy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.regcon)
	e3:SetCost(s.regcost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
	--Register attributes
	aux.GlobalCheck(s,function()
		s.attr_list={}
		s.attr_list[0]=0
		s.attr_list[1]=0
		s.card_list={}
		aux.AddValuesReset(function()
				s.attr_list[0]=0
				s.attr_list[1]=0
				for _,tab in ipairs(s.card_list) do
					for _,obj in ipairs(tab) do
						obj[1]:DeleteGroup()
					end
				end
				s.card_list={}
		end)
	end)
end

function s.checkeffects(c,e,tp,attr)
	local earth_water=attr&(ATTRIBUTE_EARTH|ATTRIBUTE_WATER)~=0
	local wind_light=attr&(ATTRIBUTE_WIND|ATTRIBUTE_LIGHT)~=0
	local dark_fire=attr&(ATTRIBUTE_DARK|ATTRIBUTE_FIRE)~=0
	
	return earth_water and s.atktg(e,tp,nil,0,0,nil,0,0,0),wind_light and s.distg(e,tp,nil,0,0,nil,0,0,0),dark_fire and s.tktg(e,tp,nil,0,0,nil,0,0,0)
end


function s.filter(c,e,tp,attributes)
	local attr=(not attributes and c:GetAttribute() or attributes[c])&(~s.attr_list[tp])
	if not (c:IsFaceup() and c:IsRace(RACE_CYBERSE) and c:GetBaseAttack()==2300 and attr~=0) then return false end
	local chk1,chk2,chk3=s.checkeffects(c,e,tp,attr)
	return chk1 or chk2 or chk3
end
function s.createcheck(c)
	return c:RegisterFlagEffect(id+1,RESET_CHAIN,0,1)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=eg:Filter(s.filter,nil,e,tp)
	if #tg==0 then return false end
	tg:KeepAlive()
	local attributes={}
	for tc in tg:Iter() do
		attributes[tc]=tc:GetAttribute()
	end
	local c=e:GetHandler()
	if not s.card_list[c] then s.card_list[c]={} end
	table.insert(s.card_list[c],{tg,s.createcheck(e:GetHandler()),attributes})
	return true
end
function s.checkvalid(e,tp)
	local res=false
	local toremove={}
	for _,obj in ipairs(s.card_list[e:GetHandler()]) do
		if type(obj[2])=="Deleted" or obj[1]:FilterCount(s.filter,nil,e,tp,obj[3])==0 then
			obj[1]:DeleteGroup()
			table.insert(toremove,1,_)
		else
			res=true
		end
	end
	for _,idx in ipairs(toremove) do
		table.remove(s.card_list[e:GetHandler()],idx)
	end
	return res
end
function s.getvalid(e,tp)
	local res=Group.CreateGroup()
	local toremove={}
	for _,obj in ipairs(s.card_list[e:GetHandler()]) do
		if type(obj[2])=="Deleted" then
			obj[1]:DeleteGroup()
			table.insert(toremove,1,_)
		end
		local sg=obj[1]:Filter(s.filter,nil,e,tp,obj[3])
		if #sg==0 then
			obj[1]:DeleteGroup()
			table.insert(toremove,1,_)
		else
			res:Merge(sg)
		end
	end
	for _,idx in ipairs(toremove) do
		table.remove(s.card_list[e:GetHandler()],idx)
	end
	return res
end
function s.removecard(e,c,tp)
	local toremove={}
	for _,obj in ipairs(s.card_list[e:GetHandler()]) do
		if obj[1]:IsContains(c) then
			obj[1]:DeleteGroup()
			table.insert(toremove,1,_)
		end
	end
	for _,idx in ipairs(toremove) do
		table.remove(s.card_list[e:GetHandler()],idx)
	end
end
function s.regcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s.checkvalid(e,tp) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=s.getvalid(e,tp)
	if chk==0 then return #g>0 end
	local sc=nil
	if #g==1 then
		sc=g:GetFirst()
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		sc=g:Select(tp,1,1,nil):GetFirst()
	end
	Duel.HintSelection(Group.FromCards(sc),true)
	s.removecard(e,sc,tp)
	
	local attr=sc:GetAttribute()&(~s.attr_list[tp])
	
	local chk1,chk2,chk3=s.checkeffects(c,e,tp,attr)
	
	local selected=-1
	
	s.attr_list[tp]=s.attr_list[tp]|attr
	
	local t=e:GetLabelObject()
	if not t then t={} end
	
	t[Duel.GetCurrentChain()]=nil
	
	if selected==0 then
		t[Duel.GetCurrentChain()]={attr,s.atkop}
	elseif selected==1 then
		t[Duel.GetCurrentChain()]={attr,s.disop}
	elseif selected==2 then
		t[Duel.GetCurrentChain()]={attr,s.tkop}
	end
	e:SetLabelObject(t)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local params=e:GetLabelObject()[Duel.GetCurrentChain()]
	if not params then return end
	local att=params[1]
	local effect=params[2]
	for _,str in aux.GetAttributeStrings(att) do
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,str)
	end
	effect(e,tp,eg,ep,ev,re,r,rp)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.nzatk,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,0,0)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,aux.nzatk,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	if tc then
		local atk=tc:GetAttack()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(math.ceil(atk/2))
		tc:RegisterEffect(e1)
	end
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.disfilter3,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local tc=Duel.SelectMatchingCard(tp,aux.disfilter3,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil):GetFirst()
	if tc and ((tc:IsFaceup() and not tc:IsDisabled()) or tc:IsType(TYPE_TRAPMONSTER)) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,11738490,0x135,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,11738490,0x135,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK) then
		local token=Duel.CreateToken(tp,11738490)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
