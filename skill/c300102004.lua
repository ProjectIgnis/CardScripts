--It's My Lucky Day!
--credit: edo9300
local s,id=aux.GetID()
function s.initial_effect(c)
    aux.AddSkillProc(c,1,false,nil,nil)
    aux.GlobalCheck(s,function()
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_TOSS_DICE_NEGATE)
        ge1:SetOperation(s.repop(Duel.GetDiceResult,Duel.SetDiceResult,{1,2,3,4,5,6,7}))
        Duel.RegisterEffect(ge1,0)    
        local ge2=ge1:Clone()
        ge2:SetCode(EVENT_TOSS_COIN_NEGATE)
        ge2:SetOperation(s.repop(Duel.GetCoinResult,Duel.SetCoinResult,{1,2}))
        Duel.RegisterEffect(ge2,0)    
    end)
end
function s.repop(func1,func2,tab)
    return function(e,tp,eg,ep,ev,re,r,rp)
        if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
            Duel.Hint(HINT_SKILL_FLIP,0,id|(1<<32))
			Duel.Hint(HINT_CARD,0,id)
			local dc={func1()}
            Duel.Hint(HINT_CARD,0,id)
            for i=1,#dc do
                dc[i]=Duel.AnnounceNumber(tp,table.unpack(tab))
            end
            func2(table.unpack(dc))
        end
    end
end