--It's My Lucky Day!
--credit: edo9300
local s,id=GetID()
local register=function(what)
	return function(...)
		local params={...}
		local tp=params[1]
		if Duel.GetFlagEffect(tp,id)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
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
		ge1:SetCode(EFFECT_TOSS_DICE_REPLACE)
		ge1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)return Duel.GetFlagEffect(ep,id)>0 and Duel.GetFlagEffectLabel(ep,id)>0 end)
		ge1:SetOperation(s.repop(Duel.GetDiceResult,Duel.SetDiceResult,function(tp) return Duel.AnnounceNumber(tp,1,2,3,4,5,6,7) end))
		Duel.RegisterEffect(ge1,0)	
		local ge2=ge1:Clone()
		ge2:SetCode(EFFECT_TOSS_COIN_REPLACE)
		ge2:SetOperation(s.repop(Duel.GetCoinResult,Duel.SetCoinResult,function(tp) return 1-Duel.AnnounceCoin(tp) end))
		Duel.RegisterEffect(ge2,0)	
	end)
end
function s.repop(func1,func2,func3)
	return function(e,tp,eg,ep,ev,re,r,rp)
		Duel.ResetFlagEffect(ep,id)
		Duel.Hint(HINT_SKILL_FLIP,0,id|(1<<32))
		Duel.Hint(HINT_CARD,0,id)
		local dc={func1()}
		local ct=(ev&0xff)+(ev>>16)
		for i=1,ct do
			dc[i]=func3(ep)
		end
		func2(table.unpack(dc))
	end
end