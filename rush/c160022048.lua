--ハンバーガーのファストレシピ
--Hamburger Fast Recipe
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Ritual Summon
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=s.ritualfil,matfilter=s.forcedgroup})
	c:RegisterEffect(e1)
end
s.listed_names={160022033,30243636}
function s.ritualfil(c)
	return c:IsCode(160022033,30243636)
end
function s.forcedgroup(c,e,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup()
end