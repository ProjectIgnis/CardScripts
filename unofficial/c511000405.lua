--機械仕掛けの夜－クロック・ワーク・ナイト－ (Anime)
--Clockwork Night (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	c:RegisterEffect(e1)
	--All monsters become Machine
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.tg)
	e2:SetValue(RACE_MACHINE)
	c:RegisterEffect(e2)
	--Change ATK by 500
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_MACHINE))
	e3:SetValue(function(e,c) return c:IsControler(e:GetHandlerPlayer()) and 500 or -500 end)
	c:RegisterEffect(e3)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(s.chk)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.chk(e,tp,eg,ep,ev,re,r,rp)
	for tc in eg:Filter(Card.IsDefensePos,nil):Iter() do
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~(RESET_TEMP_REMOVE|RESET_TURN_SET),EFFECT_FLAG_CLIENT_HINT,1,nil,aux.Stringid(id,0))
	end
end
function s.tg(e,c)
	return c:GetFlagEffect(id)==0
end