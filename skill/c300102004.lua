--It's My Lucky Day!
--credit: edo9300
local s,id=GetID()
local register=function(what)
	return function(...)
		local params={...}
		local tp=params[1]
		if Duel.CheckLPCost(tp,1000) and Duel.GetFlagEffect(tp,id)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.SetFlagEffectLabel(tp,id,1)
		end
		return what(...)
	end
end
local tossd=Duel.TossDice
Duel.TossDice=register(tossd)
local tossc=Duel.TossCoin
Duel.TossCoin=register(tossc)
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
		ge1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)return Duel.GetFlagEffect(ep,id)>0 and Duel.GetFlagEffectLabel(ep,id)>0 end)
		ge1:SetOperation(s.repop("dice",Duel.GetDiceResult,Duel.SetDiceResult,function(tp) Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3)) return Duel.AnnounceNumber(tp,1,2,3,4,5,6) end))
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EFFECT_TOSS_COIN_CHOOSE)
		ge2:SetOperation(s.repop("coin",Duel.GetCoinResult,Duel.SetCoinResult,function(tp) Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4)) return 1-Duel.AnnounceCoin(tp) end))
		Duel.RegisterEffect(ge2,0)
	end)
end
function s.repop(typ,func1,func2,func3)
	return function(e,tp,eg,ep,ev,re,r,rp)
		Duel.PayLPCost(ep,1000)
		Duel.ResetFlagEffect(ep,id)
		Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
		Duel.Hint(HINT_CARD,tp,id)
		local dc={func1()}
		local ct=(ev&0xff)+(ev>>16)
		local ac=1
		if ct>1 then
			if typ=="dice" then
				Duel.Hint(HINT_SELECTMSG,ep,aux.Stringid(id,1))
				local val,idx=Duel.AnnounceNumber(ep,table.unpack(dc,1,ct))
				ac=idx+1
			else
				local tab={}
				for i=1,ct do
					table.insert(tab,60+(1-dc[i]))
				end
				Duel.Hint(HINT_SELECTMSG,ep,aux.Stringid(id,2))
				Duel.SelectOption(ep,table.unpack(tab))
			end
			dc[ac]=func3(ep)
		else
			dc[1]=func3(ep)
		end
		func2(table.unpack(dc))
	end
end