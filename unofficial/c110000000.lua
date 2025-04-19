--ライディングデュエル
--Turbo Duel
local s,id=GetID()
function s.initial_effect(c)
	aux.EnableExtraRules(c,s,s.op)
end
function s.op(c)
	local speedWorlds={511600371,511600372,511600373,511600374}
	local playerRes={}
	for p=0,1 do
		if Duel.SelectYesNo(p,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,p,aux.Stringid(id,1))
			playerRes[p]=Duel.SelectCardsFromCodes(p,1,1,nil,false,table.unpack(speedWorlds))
		end
	end
	local res=0
	if playerRes[0] and playerRes[1] then
		Duel.Hint(HINT_MESSAGE,0,aux.Stringid(id,2))
		Duel.Hint(HINT_MESSAGE,1,aux.Stringid(id,2))
		res=playerRes[Duel.RockPaperScissors()]
	elseif not playerRes[0] and not playerRes[1] then
		Duel.Hint(HINT_MESSAGE,0,aux.Stringid(id,3))
		Duel.Hint(HINT_MESSAGE,1,aux.Stringid(id,3))
		res=speedWorlds[Duel.GetRandomNumber(1,4)]
	else
		res=playerRes[0] or playerRes[1]
	end
	for p=0,1 do
		local sW=Duel.CreateToken(p,res)
		sW:ReplaceEffect(res,0)
		Duel.MoveToField(sW,p,p,LOCATION_FZONE,POS_FACEUP,true)
	end
	--Immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_FZONE,LOCATION_FZONE)
	e1:SetValue(1)
	Duel.RegisterEffect(e1,0)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	Duel.RegisterEffect(e2,0)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_TO_DECK)
	Duel.RegisterEffect(e3,0)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CANNOT_TO_GRAVE)
	Duel.RegisterEffect(e4,0)
	local e5=e1:Clone()
	e5:SetCode(EFFECT_CANNOT_REMOVE)
	Duel.RegisterEffect(e5,0)
	local e6=e1:Clone()
	e6:SetCode(EFFECT_CANNOT_DISABLE)
	Duel.RegisterEffect(e6,0)
	local e7=e1:Clone()
	e7:SetCode(EFFECT_CANNOT_DISEFFECT)
--  Duel.RegisterEffect(e7,0)
	--Cannot Activate/Set
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e8:SetCode(EFFECT_CANNOT_TRIGGER)
	e8:SetTargetRange(1,1)
	e8:SetValue(s.aclimit)
	Duel.RegisterEffect(e8,0)
	local e9=e8:Clone()
	e9:SetCode(EFFECT_CANNOT_SSET)
	e9:SetTarget(s.aclimit2)
	Duel.RegisterEffect(e9,0)

	local isexist=Duel.IsExistingMatchingCard
		Duel.IsExistingMatchingCard=function(f,tp,int_s,int_o,count,ex,...)
		local arg={...}
		local fg=Group.CreateGroup()
		if int_s~=LOCATION_FZONE and Duel.GetFieldCard(tp,LOCATION_FZONE,0) then
			fg:AddCard(Duel.GetFieldCard(tp,LOCATION_FZONE,0))
		end
		if int_o~=LOCATION_FZONE and Duel.GetFieldCard(1-tp,LOCATION_FZONE,0) then
			fg:AddCard(Duel.GetFieldCard(1-tp,LOCATION_FZONE,0))
		end
		if arg~=nil then
			return isexist(f,tp,int_s,int_o,count,ex and fg+ex or fg,table.unpack(arg))
		else
			return isexist(f,tp,int_s,int_o,count,ex and fg+ex or fg)
		end
	end
	local getmatchg=Duel.GetMatchingGroup
		Duel.GetMatchingGroup=function(f,tp,int_s,int_o,ex,...)
		local arg={...}
		local fg=Group.CreateGroup()
		if int_s~=LOCATION_FZONE and Duel.GetFieldCard(tp,LOCATION_FZONE,0) then
			fg:AddCard(Duel.GetFieldCard(tp,LOCATION_FZONE,0))
		end
		if int_o~=LOCATION_FZONE and Duel.GetFieldCard(1-tp,LOCATION_FZONE,0) then
			fg:AddCard(Duel.GetFieldCard(1-tp,LOCATION_FZONE,0))
		end
		if arg~=nil then
			return getmatchg(f,tp,int_s,int_o,ex and fg+ex or fg,table.unpack(arg))
		else
			return getmatchg(f,tp,int_s,int_o,ex and fg+ex or fg)
		end
	end
	local getfg=Duel.GetFieldGroup
		Duel.GetFieldGroup=function(tp,int_s,int_o)
		local fg=Group.CreateGroup()
		if int_s~=LOCATION_FZONE and Duel.GetFieldCard(tp,LOCATION_FZONE,0) then
			fg:AddCard(Duel.GetFieldCard(tp,LOCATION_FZONE,0))
		end
		if int_o~=LOCATION_FZONE and Duel.GetFieldCard(1-tp,LOCATION_FZONE,0) then
			fg:AddCard(Duel.GetFieldCard(1-tp,LOCATION_FZONE,0))
		end
		return getfg(tp,int_s,int_o)-fg
	end
	local getfgc=Duel.GetFieldGroupCount
		Duel.GetFieldGroupCount=function(tp,int_s,int_o)
		return #Duel.GetFieldGroup(tp,int_s,int_o)
	end
	local getmatchgc=Duel.GetMatchingGroupCount
		Duel.GetMatchingGroupCount=function(f,tp,int_s,int_o,ex,...)
		local arg={...}
		return #Duel.GetMatchingGroup(f,tp,int_s,int_o,ex,table.unpack(arg))
	end
	local getfmatch=Duel.GetFirstMatchingCard
		Duel.GetFirstMatchingCard=function(f,tp,int_s,int_o,ex,...)
		local arg={...}
		return Duel.GetMatchingGroup(f,tp,int_s,int_o,ex,table.unpack(arg)):GetFirst()
	end
	local selmatchc=Duel.SelectMatchingCard
		Duel.SelectMatchingCard=function(sp,f,tp,int_s,int_o,min,max,ex, ...)
		local arg={...}
		local fg=Group.CreateGroup()
		if int_s~=LOCATION_FZONE and Duel.GetFieldCard(tp,LOCATION_FZONE,0) then
			fg:AddCard(Duel.GetFieldCard(tp,LOCATION_FZONE,0))
		end
		if int_o~=LOCATION_FZONE and Duel.GetFieldCard(1-tp,LOCATION_FZONE,0) then
			fg:AddCard(Duel.GetFieldCard(1-tp,LOCATION_FZONE,0))
		end
		if arg~=nil then
			return selmatchc(sp,f,tp,int_s,int_o,min,max,ex and fg+ex or fg,table.unpack(arg))
		else
			return selmatchc(sp,f,tp,int_s,int_o,min,max,ex and fg+ex or fg)
		end
	end

end
function s.aclimit(e,re)
	return re:GetHandler():IsType(TYPE_FIELD)
end
function s.aclimit2(e,c)
	return c:IsType(TYPE_FIELD)
end