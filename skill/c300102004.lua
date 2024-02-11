--It's My Lucky Day!
--credit: edo9300
local s,id=GetID()
local function check_and_register_flag(tp)
	if Duel.CheckLPCost(tp,1000) and Duel.GetFlagEffect(tp,id)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.SetFlagEffectLabel(tp,id,1)
	end
end
s.roll_dice=true
Duel.TossDice=(function()
	local oldf=Duel.TossDice
	--technically this also has a count2 for the opponent, leave it
	--unhandled for now as the core lacks the capabilities
	return function(tp,count,...)
		if count>0 then check_and_register_flag(tp) end
		return oldf(tp,count,...)
	end
end)()
Duel.TossCoin=(function()
	local oldf=Duel.TossCoin
	return function(tp,count,...)
		if count>0 then check_and_register_flag(tp) end
		return oldf(tp,count,...)
	end
end)()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetRange(0x5f)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)Duel.RegisterFlagEffect(tp,id,0,0,0) e:Reset() end)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EFFECT_TOSS_DICE_CHOOSE)
		ge1:SetCondition(function(e,tp,eg,ep)return (Duel.GetFlagEffectLabel(ep,id) or 0)>0 end)
		ge1:SetOperation(s.repop(true,Duel.SetDiceResult,function(tp)
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
			return Duel.AnnounceNumberRange(tp,1,6)
		end))
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EFFECT_TOSS_COIN_CHOOSE)
		ge2:SetOperation(s.repop(false,Duel.SetCoinResult,function(tp)
			return Duel.AnnounceCoin(tp,aux.Stringid(id,4))
		end))
		Duel.RegisterEffect(ge2,0)
	end)
end
function s.repop(isdice,func2,func3)
	return function(e,tp,eg,ep,ev,re,r,rp)
		Duel.PayLPCost(ep,1000)
		Duel.ResetFlagEffect(ep,id)
		Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
		Duel.Hint(HINT_CARD,tp,id)
		local total=(ev&0xff)+(ev>>16)
		local res={}
		res[1]=func3(ep)
		for i=2,total do
			if isdice then
				table.insert(res,Duel.GetRandomNumber(1,6))
			else
				table.insert(res,Duel.GetRandomNumber(0,1)==0 and COIN_TAILS or COIN_HEADS)
			end
		end
		func2(table.unpack(res))
	end
end
